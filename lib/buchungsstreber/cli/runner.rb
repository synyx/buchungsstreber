require 'open3'

require 'buchungsstreber/cli/app'

module Buchungsstreber
  module CLI
    class Runner
      # Allow everything fun to be injected from the outside while defaulting to normal implementations.
      def initialize(argv, stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = Kernel)
        @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel

        unless kernel.respond_to?(:exec)
          kernel.send(:define_singleton_method, :exec) do |cmd, *params|
            Thread.new do
              STDERR.puts("entering exec #{cmd} #{params.inspect}")
              rc = nil
              l = lambda do |n,i,o|
                lambda do
                  begin
                    #STDERR.puts([n, 'setup',i,o,i.closed?,o.closed?].inspect)
                    #STDERR.puts([n, i.length, i.string].inspect) if i.kind_of?(StringIO)
                    nr = 0
                    while true
                      begin
                        #STDERR.puts(['in',i,o,i.closed?,o.closed?].inspect)
                        if i.kind_of?(StringIO)
                          STDERR.puts '%s <%s->%s> | %s[%d]' % [n, i,o,i.string.inspect,nr]
                          nr += o.write(i.string[nr..-1])
                          if o.closed? || i.closed?
                            throw EOFError.new('closed from writing stringio')
                          end
                          Kernel.sleep(0.1)
                        else
                          STDERR.puts '%s <%s->%s>' % [n, i,o]
                          result = i.read_nonblock(1024)
                          STDERR.puts '%s <%s->%s> | %s' % [n, i,o,result.inspect]
                          o.write(result)
                          STDERR.puts '%s <%s->%s> & %s' % [n, i,o,result.inspect]
                        end
                      rescue IO::WaitReadable
                        #STDERR.puts([n, 'readable1',i,o,i.closed?,o.closed?].inspect)
                        IO.select([i])
                        #STDERR.puts([n, 'readable2',i,o,i.closed?,o.closed?].inspect)
                        retry
                      rescue IO::WaitWritable
                        #STDERR.puts([n, 'writeable1',i,o,i.closed?,o.closed?].inspect)
                        IO.select(nil, [o])
                        #STDERR.puts([n, 'writeable2',i,o,i.closed?,o.closed?].inspect)
                        retry
                      rescue EOFError
                        if i.kind_of?(StringIO)
                          # there could be more...
                          STDERR.puts '%s <%s> EOF' % [n, i]
                        else
                          STDERR.puts '%s <%s> EOF' % [n, i]
                          if i.eof?
                            STDERR.puts '%s <%s> CLOSE (in <%s> was closed)' % [n, o,i]
                            o.close
                            break
                          end
                        end
                        retry
                      rescue IOError => e
                        STDERR.puts '%s <%s,%s> ERR %s' % [n, i,o, e.message]
                        retry unless e.message =~ /closed/
                        STDERR.puts '%s <%s,%s> CLOSE IOError' % [n, i,o]
                        i.close
                        o.close
                        break
                      end
                    end
                  rescue Exception => e
                    STDERR.puts([n, e.class.name, e.message, e.backtrace].inspect)
                  end
                end
              end
              STDOUT.puts([0, [cmd, *params]].inspect)
              Open3.popen3(cmd, *params) do |in_, out_, err_, t|
                out_reader = Thread.new(&l.call('out', out_, stdout))
                err_reader = Thread.new(&l.call('err', err_, stderr))
                in_writer = Thread.new(&l.call('in', stdin, in_))
                STDOUT.puts([1, [cmd, *params], out_reader, err_reader, in_writer].inspect)
                STDERR.puts("waiting for threads to exit")
                [out_reader, err_reader, in_writer].each { |th| th.join }
                STDOUT.puts([2, out_reader, err_reader, in_writer].inspect)
                rc = t.value.exitstatus
                STDOUT.puts([3, out_reader, err_reader, in_writer].inspect)

                STDERR.puts("exiting exec")
                kernel.exit(rc)
              end
            end.join
          end
        end
      end

      def execute!
        exit_code = begin
                      # Thor accesses these streams directly rather than letting them be injected, so we replace them...
                      $stderr = @stderr
                      $stdin = @stdin
                      $stdout = @stdout
                      Buchungsstreber::CLI::App.class_variable_set(:@@kernel, @kernel)

                      # Run our normal Thor app the way we know and love.
                      Buchungsstreber::CLI::App.start(@argv)

                      # Thor::Base#start does not have a return value, assume success if no exception is raised.
                      0
                    rescue StandardError => e
                      # The ruby interpreter would pipe this to STDERR and exit 1 in the case of an unhandled exception
                      b = e.backtrace
                      @stderr.puts("#{b.shift}: #{e.message} (#{e.class})")
                      @stderr.puts(b.map { |s| "\tfrom #{s}" }.join("\n"))
                      1
                    rescue SystemExit => e
                      e.status
                    ensure
                      # TODO: reset your app here, free up resources, etc.
                      # Examples:
                      # MyApp.logger.flush
                      # MyApp.logger.close
                      # MyApp.logger = nil
                      #
                      # MyApp.reset_singleton_instance_variables

                      Buchungsstreber::CLI::App.class_variable_set(:@@kernel, Kernel)
                      # ...then we put the streams back.
                      $stderr = STDERR
                      $stdin = STDIN
                      $stdout = STDOUT
                    end

        # Proxy our exit code back to the injected kernel.
        @kernel.exit(exit_code)
      end
    end
  end
end
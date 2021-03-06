require 'open3'

require_relative 'app'

module Buchungsstreber
  module CLI
    class Runner
      # Allow everything fun to be injected from the outside while defaulting to normal implementations.
      def initialize(argv, stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = Kernel)
        @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
      end

      def execute!
        # Thor accesses these streams directly rather than letting them be injected, so we replace them...
        $stderr = @stderr
        $stdin = @stdin
        $stdout = @stdout

        # Run our normal Thor app the way we know and love.
        Buchungsstreber::CLI::App.start(@argv)

        # Thor::Base#start does not have a return value, assume success if no exception is raised.
        @kernel.exit(0)
      rescue StandardError => e
        # The ruby interpreter would pipe this to STDERR and exit 1 in the case of an unhandled exception
        b = e.backtrace
        @stderr.puts("#{b.shift}: #{e.message} (#{e.class})")
        @stderr.puts(b.map { |s| "\tfrom #{s}" }.join("\n"))
        @kernel.exit(1)
      rescue SystemExit => e
        # Proxy our exit code back to the injected kernel.
        @kernel.exit(e.status)
      ensure
        # ...then we put the streams back.
        $stderr = STDERR
        $stdin = STDIN
        $stdout = STDOUT
      end
    end
  end
end

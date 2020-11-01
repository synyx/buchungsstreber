require 'logger'

module Buchungsstreber
  module Logging
    def self.logger(progname)
      unless defined? @logfile
        @logfile = File.open('err.out', File::WRONLY | File::APPEND | File::CREAT)
        @logfile.sync = true
        @logger = {}
        @formatter = proc do |severity, datetime, prog, msg|
          dt = datetime.strftime('%Y-%m-%d %H:%M:%S.%6N')
          tid = Thread.current.object_id
          "%<t>s [%<tid>X] % 5<s>s -- %<p>s: %<msg>s\n" % { t: dt, tid: tid, s: severity, p: prog, msg: msg }
        end
      end
      if @logger[progname]
        @logger[progname]
      else
        @logger[progname] = Logger.new(@logfile)
        @logger[progname].formatter = @formatter
        @logger[progname].progname = progname
        @logger[progname].level = Logger::DEBUG
        @logger[progname].info 'started logging'
      end
      @logger[progname]
    end

    def self.included(base)
      class << base
        def log
          Logging.logger(base.name)
        end
      end
    end

    def log
      Logging.logger(self.class.name)
    end
  end
end

require 'logger'

module Buchungsstreber
  module Logging
    def self.logger(progname)
      unless defined? @logfile
        @logfile = File.open('err.out', File::WRONLY | File::APPEND | File::CREAT)
        @logfile.sync = true
        @logger = {}
      end
      if @logger[progname]
        @logger[progname]
      else
        @logger[progname] = Logger.new(@logfile)
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

class Buchungsstreber::Watcher
  # Watches the given file.
  # It will block until the file is removed.
  #
  # @param file to watch for changes
  #
  # @yield [file] the changed file
  # @yieldparam [String] file the changed file as absolute path
  def self.watch(_file)
    throw 'Watch not implemented, install filewatcher or listen gem'
  end

  class <<self
    begin
      require 'filewatcher'
      def watch(file, &block)
        fw = Filewatcher.new(file)
        fw.watch do |f, event|
          case event
          when 'created', 'updated'
            block.call(f)
          when 'deleted'
            # assume it will be recreated
          else
            # ignore any other events
          end
        end
      end
    rescue LoadError
      # defer error handling to the default method
    end

    begin
      require 'listen'
      def watch(file, &block)
        mutex = Mutex.new
        resource = ConditionVariable.new
        listener = Listen.to(File.dirname(file)) do |modified, added, removed|
          if !(modified + added).empty?
            block.call(file)
          elsif !removed.empty?
            mutex.synchronize { resource.signal }
          end
        end
        listener.only(/#{File.basename(file)}/)
        listener.start
        Thread.start(listener) { |_l| mutex.synchronize { resource.wait(mutex) } }.join
      end
    rescue LoadError
      # defer error handling to the default method
    end

    begin
      require 'rb-inotify'
      def watch(file, &block)
        mutex = Mutex.new
        resource = ConditionVariable.new
        notifier = INotify::Notifier.new
        notifier.watch file, :modify, :attrib do |_event|
          block.call(file)
        end
        notifier.watch File.dirname(file), :delete, :create do |event|
          if event.name == File.basename(file)
            case event.flags[-1]
            when :create
              block.call(file)
            when :delete
              mutex.synchronize { resource.signal }
            else
              # ignore any other events
            end
          end
        end
        Thread.start(notifier) { |n| mutex.synchronize { resource.wait(mutex); n.stop } }
        notifier.run
      end
    rescue LoadError
      # defer error handling to the default method
    end
  end
end

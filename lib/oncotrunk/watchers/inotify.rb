require 'rb-inotify'

module Oncotrunk::Watchers
  class INotify
    def initialize
      @notifier = ::INotify::Notifier.new
    end

    def watch(base_path, &block)
      base_path = File.expand_path(base_path)
      @notifier.watch(base_path, :recursive, :close_write, :moved_to, :moved_from, :create, :delete) do |event|
        block.call event.absolute_name.split(base_path+"/", 2)[1]
      end
    end

    def run!
      @notifier.run
    end
  end
end

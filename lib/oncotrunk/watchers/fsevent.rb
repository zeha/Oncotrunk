require 'rb-fsevent'

module Oncotrunk::Watchers
  class FSEvent
    def initialize
      @notifier = ::FSEvent.new
    end

    def watch(base_path, &block)
      options = {:latency => 1}
      base_path = File.expand_path(base_path)
      @notifier.watch(base_path, options) do |paths|
        paths.each do |changed_path|
          block.call changed_path.split(base_path+"/", 2)[1]
        end
      end
    end

    def run!
      @notifier.run
    end
  end
end

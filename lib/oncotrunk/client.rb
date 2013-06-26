require 'socket'
require 'xmpp4r'
require 'xmpp4r/pubsub'

module Oncotrunk
  class Client
    def initialize(settings = nil)
      @settings = settings
      @settings ||= Oncotrunk::Settings.new
      @settings.ensure_config

      @service = @settings['pubsub.server']
      @node = (@settings['pubsub.node'] || '/Oncotrunk/:jid').gsub!(':jid', @settings['jabber.jid'])
      @local_path = File.expand_path(@settings['local'])
      @remote_path = @settings['remote']

      if @settings['debug'] == 1
        Jabber::debug = true
      end

      @syncer = Oncotrunk::Syncer.new

      hostname = Socket.gethostname
      @myinstance = hostname + '_' + (rand()*20000000).to_i.to_s

      @client = Jabber::Client.new(Jabber::JID.new(@settings['jabber.jid'] + '/' + @myinstance))
      @client.connect
      @client.auth(@settings['jabber.password'])
      @client.send(Jabber::Presence.new.set_type(:available))
    end

    def publish(event_type, payload)
      item = Jabber::PubSub::Item.new
      xml = REXML::Element.new(event_type)
      xml.text = payload
      xml.add_attribute('from_instance', @myinstance)
      item.add(xml)
      @pubsub.publish_item_to(@node, item)
    end

    def sync
      @syncer.sync @local_path, @remote_path
    end

    def register_watches
      @watcher = Oncotrunk::Watcher.new
      @watcher.watch(@local_path) do |filename|
        sync
        publish("file_change", filename)
      end

      puts "Watching directory #{@local_path} ..."
    end

    def register_pubsub
      @pubsub = Jabber::PubSub::ServiceHelper.new(@client, @service)
      begin
        @pubsub.subscribe_to(@node)
      rescue Jabber::ServerError => e
        if e.message.include?("item-not-found")
          # create node and retry subscribe
          @pubsub.create_node(@node)
          @pubsub.subscribe_to(@node)
        else
          raise e
        end
      end
        
      @pubsub.add_event_callback do |event|
        event.payload.each do |items|
          items.each do |item|
            item.each do |payload|
              puts payload
              if payload.attributes['from_instance'] == @myinstance
                puts "  ignoring loopback event"
              else
                method = "on_#{payload.name}"
                if self.respond_to?(method)
                  self.send(method, item)
                else
                  puts "  Unhandled event #{method}"
                end
              end
            end
          end
        end
      end
    end

    def on_file_change(event)
      sync
    end

    def on_restarted(event)
      sync
    end

    def start!
      puts "Oncotrunk starting..."
      # initial sync before we register filesystem hooks
      sync
      # register event sources
      register_watches
      register_pubsub
      # tell everybody else that we're alive now (and that files may have changed because of that)
      publish("restarted", "")
      @watcher.run!
    end
  end
end

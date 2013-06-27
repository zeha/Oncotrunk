require 'socket'
require 'xmpp4r'
require 'xmpp4r/pubsub'
require 'eventmachine'

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

      @pending_events = []
      @changed_paths = []
      @locally_changed = []
    end

    def publish(event_type, payload)
      item = Jabber::PubSub::Item.new
      xml = REXML::Element.new(event_type)
      xml.text = payload
      xml.add_attribute('from_instance', @myinstance)
      item.add(xml)
      @pubsub.publish_item_to(@node, item)
    end

    def sync(path=nil)
      @syncer.sync @local_path, @remote_path, path
    end

    def register_watches
      @watcher = Oncotrunk::Watcher.new
      @watcher.watch(@local_path) do |filename|
        @pending_events << ["local", "file_change", filename]
      end

      Oncotrunk.ui.info "Watching directory #{@local_path} ..."
    end

    def register_pubsub
      begin
        @jabber_client = Jabber::Client.new(Jabber::JID.new(@settings['jabber.jid'] + '/' + @myinstance))
        @jabber_client.connect
        @jabber_client.auth(@settings['jabber.password'])
        @jabber_client.send(Jabber::Presence.new.set_type(:available))
      rescue StandardError => e
        raise JabberError, "Jabber: #{e.message}"
      end

      @pubsub = Jabber::PubSub::ServiceHelper.new(@jabber_client, @service)
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
              if payload.attributes['from_instance'] != @myinstance
                @pending_events << ["remote", payload.name, payload.text]
              end
            end
          end
        end
      end
    end

    def on_local_file_change(filename)
      @changed_paths << filename
      @locally_changed << filename
    end

    def on_remote_file_change(filename)
      @changed_paths << filename
    end

    def on_remote_restarted(payload)
      sync
    end

    def handle_events
      @pending_events.uniq!
      while not @pending_events.empty? do
        event = @pending_events.shift

        (source, name, payload) = event
        Oncotrunk.ui.info ">> #{source} #{name}: #{payload}"

        method = "on_#{source}_#{name}"
        if self.respond_to?(method)
          self.send(method, payload)
        else
          Oncotrunk.ui.warn "  Unhandled event #{method}"
        end
      end
      unless @changed_paths.empty?
        changed_paths = @changed_paths.dup
        @changed_paths = []
        sync @changed_paths
      end
      while p = @locally_changed.shift do
        publish "file_change", p
      end
    end

    def run!
      # initial sync before we register filesystem hooks
      sync
      # register event sources
      register_pubsub
      # tell everybody else that we're alive now (and that files may have changed because of that)
      publish("restarted", "")
      register_watches

      Thread.new do
        @watcher.run!
      end

      EventMachine.run do
        EventMachine.add_periodic_timer(1) do
          handle_events
        end
      end
      Oncotrunk.ui.info "Exiting"
    end

  end
end

require 'thor'

module Oncotrunk
  class CLI < Thor
    include Thor::Actions

    package_name "Oncotrunk " + Oncotrunk::VERSION

    def initialize(*)
      super
      Oncotrunk.ui = UI::Shell.new
      Oncotrunk.ui.level = "debug" if options["verbose"]
    end

    class_option "verbose", :type => :boolean, :banner => "Enable verbose output/logging", :aliases => "-v"
    check_unknown_options!

    desc "start", "start syncing daemon"
    def start
      @client = Oncotrunk::Client.new
      @client.connect
      @client.run!
    end

    desc "version", "Prints Oncotrunk's version"
    def version
      Oncotrunk.ui.info "Oncotrunk version #{Oncotrunk::VERSION}"
    end
    map %w(-V --version) => :version

  end
end

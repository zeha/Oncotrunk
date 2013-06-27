require 'thor'
require 'daemons'
require 'fileutils'

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
    def start(foreground=false)
      @client = Oncotrunk::Client.new
      @client.connect

      Oncotrunk.ui.info "Backgrounding..."
      FileUtils.mkdir_p daemons_opts[:dir]

      opts = daemons_opts.merge(:ontop => foreground)
      Daemons.daemonize opts

      # Switch to daemon appropiate UI (== logs)
      ui_level = Oncotrunk.ui.level
      Oncotrunk.ui = UI::Daemon.new
      Oncotrunk.ui.level = ui_level

      @client.run!
    end

    desc "stop", "stop syncing daemon"
    def stop
      opts = daemons_opts.merge(:ARGV => ['stop'])
      Daemons.run("dummy", opts)
    end

    desc "version", "Prints Oncotrunk's version"
    def version
      Oncotrunk.ui.info "Oncotrunk version #{Oncotrunk::VERSION}"
    end
    map %w(-V --version) => :version


    private

    def daemons_opts
      {
        :app_name => "Oncotrunk",
        :multiple => false,
        :dir_mode => :normal,
        :dir => File.join(Oncotrunk.cachedir_path, 'daemon'),
        :backtrace => true
      }
    end

  end
end

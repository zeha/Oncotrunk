require 'yaml'

module Oncotrunk
  class Settings
    def initialize(path = nil)
      @path = File.expand_path(path || default_path)
      if File.exists?(@path)
        @settings = YAML.load(File.read(@path))
      end
      @settings ||= {}
    end

    def default_path
      platform = RUBY_PLATFORM.downcase
      if platform.include?("darwin")
        "~/Library/Oncotrunk/settings.yml"
      elsif platform.include?("mswin")
        File.join(ENV["APPDATA"], "Oncotrunk", "settings.yml")
      else
        "~/.config/Oncotrunk/settings.yml"
      end
    end

    def [](key)
      @settings[key]
    end

    def ensure_config
      if not File.exists?(@path)
        defaults = {
          'jabber.jid' => 'jid@localhost',
          'jabber.password' => '',
          'pubsub.server' => 'pubsub.localhost',
          'local' => '~/LOCAL_SYNCED_PATH',
          'remote' => 'ssh://REMOTE_SERVER/REMOTE_DIRECTORY',
        }
        FileUtils.mkdir_p File.expand_path(File.join(@path, ".."))
        File.open(@path, 'w') do |f|
          f.write YAML.dump(defaults)
        end
        raise ConfigCreatedError, "A new config file has been created for you in #{@path}. Please edit and restart."
      end
      ensure_setting_present 'jabber.jid'
      ensure_setting_present 'jabber.password'
      ensure_setting_present 'local'
      ensure_setting_present 'remote'
      ensure_setting_present 'pubsub.server'
    end

    private

    def ensure_setting_present(key)
      if @settings[key].nil? || @settings[key].empty?
        raise ConfigBrokenError, "Please edit the config file in #{@path} and set \"#{key}\"."
      end
    end
  end
end

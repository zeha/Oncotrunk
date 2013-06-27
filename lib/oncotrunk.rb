require 'oncotrunk/version'

module Oncotrunk

  autoload :Client,      'oncotrunk/client'
  autoload :Settings,    'oncotrunk/settings'
  autoload :Syncer,      'oncotrunk/syncer'
  autoload :UI,          'oncotrunk/ui'
  autoload :Watcher,     'oncotrunk/watcher'

  class OncotrunkError < StandardError
    def self.status_code(code)
      define_method(:status_code) { code }
    end
  end

  class ConfigCreatedError < OncotrunkError
    status_code(2)
  end

  class ConfigBrokenError < OncotrunkError
    status_code(3)
  end

  class JabberError < OncotrunkError
    status_code(4)
  end

  class SyncFailedError < OncotrunkError
    status_code(5)
  end


  class << self
    attr_writer :ui

    def ui
      @ui ||= UI.new
    end

    def settings
      @settings ||= Settings.new
    end

    def cachedir_name
      ".oncotrunk"
    end

    def cachedir_path
      File.join(File.expand_path(Oncotrunk.settings['local']), Oncotrunk.cachedir_name)
    end

  end

end

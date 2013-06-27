require 'etc'
require 'syslog'

module Oncotrunk
  class UI
    LEVELS = %w(error warn info debug)

    def initialize
      @level = "info"
    end

    def debug(msg)
      handle("debug", msg)
    end

    def info(msg)
      handle("info", msg)
    end

    def warn(msg)
      handle("warn", msg)
    end

    def error(msg)
      handle("error", msg)
    end

    def level=(level)
      raise ArgumentError unless LEVELS.include?(level)
      @level = level
    end

    def level
      @level
    end

    def visible?(name)
      LEVELS.index(name) <= LEVELS.index(@level)
    end


    class Shell < UI
      def initialize
        super
        if !STDOUT.tty?
          Thor::Base.shell = Thor::Shell::Basic
        end
        @shell = Thor::Base.shell.new
      end

      def trace(e)
        msg = ["#{e.class}: #{e.message}", *e.backtrace].join("\n")
        error msg
        STDERR.puts "#{msg}\n"
      end

      def handle(level, msg)
        @shell.say(msg, color(level)) if visible?(level)
      end

      def color(level)
        case level
        when "info"
          :green
        when "warn"
          :yellow
        when "error"
          :red
        else
          nil
        end
      end

    end


    class Daemon < UI
      def initialize
        super
        @syslog = Syslog.open("Oncotrunk-#{Etc.getlogin}", Syslog::LOG_PID)
      end

      def trace(e)
        msg = ["#{e.class}: #{e.message}", *e.backtrace].join(" ")
        handle("error", msg)
      end

      def handle(level, msg)
        @syslog.notice "%s", "#{level}: #{msg}" if visible?(level)
      end

    end

  end
end

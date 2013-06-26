module Oncotrunk
  class UI
    LEVELS = %w(error warn info debug)

    def debug(msg)
    end

    def info(msg)
    end

    def warn(msg)
    end

    def error(msg)
    end

    def level=(level)
      @level = level
    end

    def visible?(name)
      LEVELS.index(name) <= LEVELS.index(@level)
    end

    class Shell < UI
      def initialize
        if !STDOUT.tty?
          Thor::Base.shell = Thor::Shell::Basic
        end
        @shell = Thor::Base.shell.new
        @level = "info"
      end

      def trace(e)
        msg = ["#{e.class}: #{e.message}", *e.backtrace].join("\n")
        error msg
        STDERR.puts "#{msg}\n"
      end

      def debug(msg)
        @shell.say(msg) if visible?("debug")
      end

      def info(msg)
        @shell.say(msg, :green) if visible?("info")
      end

      def warn(msg)
        @shell.say(msg, :yellow) if visible?("warn")
      end

      def error(msg)
        @shell.say(msg, :red) if visible?("info")
      end
    end

  end
end

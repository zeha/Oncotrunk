require 'posix/spawn'

module Oncotrunk
  class Syncer
    def initialize
      @profile = "oncotrunk"
      @unison_config_path = File.expand_path("~/.unison")
      if RUBY_PLATFORM.downcase.include?("darwin")
        @unison_config_path = File.expand_path("~/Library/Application Support/Unison")
      end
    end

    def sync(local, remote, path=nil)
      ensure_profile
      max_tries = 10
      tries = 0
      while tries < max_tries
        if run_unison(local, remote, path)
          Oncotrunk.ui.info "Sync complete"
          return
        end
        tries += 1
      end
      raise SyncFailedError, "Unison did not complete after #{max_tries} tries"
    end

    def run_unison(local, remote, path=nil)
      program = "unison"
      args = [@profile, "-root", local, "-root", remote, "-batch", "-auto", "-dumbtty", "-ignore", "Path #{Oncotrunk.cachedir_name}", "-sortbysize"]

      Oncotrunk.ui.debug "#{program} #{args.join(" ")}"

      r,w = IO.pipe
      options = {:in => "/dev/null", 2=>1, :out => w}
      pid = POSIX::Spawn::spawn(program, *args, options)
      w.close
      Process.waitpid(pid)
      Oncotrunk.ui.info "unison: #{r.read}"

      case $?.exitstatus
      when 0
        # did some work
        return true
      when 1
        # nothing to sync
        return true
      when 3
        # locked
        return false
      when 2
        # update failed
        return false
      else
        raise SyncFailedError, "Unhandled unison exit code #{$?.exitstatus}"
      end
    end

    def ensure_profile
      if not File.exists?(@unison_config_path)
        %x{unison 1>&2 2>/dev/null}
      end
      profile_file = File.join(@unison_config_path, "#{@profile}.prf")
      if not File.exists?(profile_file)
        File.open(profile_file, 'w') do |f|
          f.write("# Automatically generated by Oncotrunk")
        end
      end
    end
  end
end

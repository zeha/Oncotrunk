if RUBY_PLATFORM.downcase.include?('linux')
  require 'oncotrunk/watchers/inotify'
  Oncotrunk::Watcher = Oncotrunk::Watchers::INotify
elsif RUBY_PLATFORM.downcase.include?('darwin')
  require 'oncotrunk/watchers/fsevent'
  Oncotrunk::Watcher = Oncotrunk::Watchers::FSEvent
else
  raise "No Oncotrunk::Watcher found for this platform (#{RUBY_PLATFORM})"
end

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oncotrunk/version'

Gem::Specification.new do |spec|
  spec.name          = "oncotrunk"
  spec.version       = Oncotrunk::VERSION
  spec.authors       = ["Christian Hofstaedtler"]
  spec.email         = ["ch@zeha.at"]
  spec.description   = %q{PubSub based file syncing daemon, requires unison}
  spec.summary       = %q{PubSub based file syncing daemon, requires unison}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "xmpp4r"
  spec.add_dependency "rb-inotify"
  spec.add_dependency "rb-fsevent"
  spec.add_dependency "posix-spawn" # only for 1.8.7 backwards compat
  spec.add_dependency "thor"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ayadn/version'

Gem::Specification.new do |spec|
  spec.name          = "ayadn"
  spec.version       = Ayadn::VERSION
  spec.author       = "Eric Dejonckheere"
  spec.email         = ["eric@aya.io"]
  spec.summary       = %q{App.net command-line client.}
  spec.description   = %q{App.net command-line client: power tool to access and manage your ADN data, show your streams, manage conversations, star/follow/repost... and many, many more.}
  spec.homepage      = "http://ayadn-app.net"
  spec.license       = "Custom"

  spec.bindir        = 'bin'
  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = %w{ayadn}
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 1.9.3'
  spec.add_dependency "thor", "~> 0.18"
  #spec.add_dependency "json"
  spec.add_dependency "rest-client", "~> 1.6"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 10.1"

  spec.post_install_message = "Thanks for installing Ayadn! Please run 'ayadn auth' to login with your App.net credentials."
end

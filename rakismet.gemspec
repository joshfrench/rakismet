# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rakismet/version', __FILE__)

Gem::Specification.new do |s|
  s.name = "rakismet"
  s.version = Rakismet::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors = ["Josh French"]
  s.email = "josh@vitamin-j.com"
  s.homepage = "http://github.com/joshfrench/rakismet"
  s.summary = "Akismet and TypePad AntiSpam integration for Rails."
  s.description = "Rakismet is the easiest way to integrate Akismet or TypePad's AntiSpam into your Rails app."
  s.date = "2012-04-22"

  s.rubyforge_project = "rakismet"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 2.11"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.extra_rdoc_files = ["README.md"]
end


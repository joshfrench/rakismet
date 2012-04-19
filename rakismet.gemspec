# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rakismet/version"

Gem::Specification.new do |s|
  s.name = "rakismet"
  s.version = Rakismet::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors = ["Josh French"]
  s.email = "josh@vitamin-j.com"
  s.homepage = "http://github.com/joshfrench/rakismet"
  s.summary = "Akismet and TypePad AntiSpam integration for Rails."
  s.description = "Rakismet is the easiest way to integrate Akismet or TypePad's AntiSpam into your Rails app."
  s.date = "2012-04-19"

  s.rubyforge_project = "rakismet"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.extra_rdoc_files = ["README.md"]
end


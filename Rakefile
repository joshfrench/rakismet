require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rakismet"
    gem.summary = %Q{Akismet and TypePad AntiSpam integration for Rails.}
    gem.description = %Q{Rakismet is the easiest way to integrate Akismet or TypePad's AntiSpam into your Rails app.}
    gem.email = "josh@digitalpulp.com"
    gem.homepage = "http://github.com/joshfrench/rakismet"
    gem.authors = ["Josh French"]
    gem.rubyforge_project = %q{rakismet}
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |spec|
  spec.rspec_opts = ["--color", "--format progress"]
end

task :default => :spec
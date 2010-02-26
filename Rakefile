require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rakismet"
    gem.summary = %Q{Akismet and TypePad AntiSpam integration for Rails.}
    gem.description = %Q{Rakismet is the easiest way to integrate Akismet or TypePad's AntiSpam into your Rails app.}
    gem.email = "josh@digitalpulp.com"
    gem.homepage = "http://github.com/jfrench/rakismet"
    gem.authors = ["Josh French"]
    gem.rubyforge_project = %q{rakismet}
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

task :default => :spec
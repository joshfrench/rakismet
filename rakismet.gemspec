# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rakismet}
  s.version = "0.3.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Josh French"]
  s.date = %q{2009-09-16}
  s.description = %q{Rakismet is easy Akismet integration with your Rails app, including support for TypePad's AntiSpam service. This version is a fork Josh French's rakismet plugin.}
  s.email = %q{systems@inspiredigital.com.au}
  s.extra_rdoc_files = ["README.md", "MIT-LICENSE"]
  s.files = ["CHANGELOG", "README.md", "rails/init.rb", "lib/rakismet.rb", "lib/rakismet", "lib/rakismet/controller_extensions.rb", "lib/rakismet/model_extensions.rb", "MIT-LICENSE"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/inspiredigital/rakismet}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rakismet}
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{Rakismet is easy Akismet integration with your Rails app, including support for TypePad's AntiSpam service. This version is a fork Josh French's rakismet plugin.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3
 
    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
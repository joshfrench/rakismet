ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'spec'
require 'spec/rails'

Spec::Runner.configure do |config|

end

class Class
  # Creates a new subclass of self, with a name "under" our own name. Example:
  #
  #     x = Foo::Bar.subclass('Zap'){}
  #     x.name # => Foo::Bar::Zap_1
  #     x.superclass.name # => Foo::Bar
  #
  # Removed from RSpec after 1.1.something; reproduced here because much of the
  # spec suite was already written with dynamic class creation.
  def subclass(base_name, &body)
    klass = Class.new(self)
    class_name = "#{self.name}_#{base_name}"
    instance_eval do
      const_set(class_name, klass)
    end
    klass.instance_eval(&body)
    klass
  end
end
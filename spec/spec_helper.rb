require File.expand_path "lib/rakismet"

RSpec.configure do |config|
  config.mock_with :rspec
end

class Class
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

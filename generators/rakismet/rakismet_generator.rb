class RakismetGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      m.file "config/initializers/rakismet.rb", "config/initializers/rakismet.rb"
    end
  end
end

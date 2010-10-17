require 'rails'
require 'rakismet'

module Rakismet
  class Railtie < Rails::Railtie
      config.rakismet = ActiveSupport::OrderedOptions.new
      config.rakismet.host = 'rest.akismet.com'
      initializer 'rakismet.get_config' do |app|
        Rakismet.key = app.config.rakismet.key
        Rakismet.url = app.config.rakismet.url
        Rakismet.host = app.config.rakismet.host
      end
      initializer 'rakismet.add_middleware' do |app|
        app.middleware.use Rakismet::Middleware
      end
  end
end

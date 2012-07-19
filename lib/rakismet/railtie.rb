require 'rails'
require 'rakismet'

module Rakismet
  class Railtie < Rails::Railtie

      config.rakismet = ActiveSupport::OrderedOptions.new
      config.rakismet.host = 'rest.akismet.com'
      config.rakismet.use_middleware = true

      initializer 'rakismet.setup', :after => :load_config_initializers do |app|
        Rakismet.key = app.config.rakismet[:key]
        Rakismet.url = app.config.rakismet[:url]
        Rakismet.host = app.config.rakismet[:host]
        Rakismet.proxy_host = app.config.rakismet[:proxy_host]
        Rakismet.proxy_port = app.config.rakismet[:proxy_port]
        Rakismet.test = app.config.rakismet.fetch(:test) { Rails.env.test? || Rails.env.development? }
        app.middleware.use Rakismet::Middleware if app.config.rakismet.use_middleware
      end

  end
end

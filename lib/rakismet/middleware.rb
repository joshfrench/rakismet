module Rakismet
  class Middleware

    def initialize(app)
      @app = app
    end

    def call(env)
      Rakismet.set_request_vars(env)
      @app.call(env)
      Rakismet.clear_request
    end

  end
end

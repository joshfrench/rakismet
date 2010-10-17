module Rakismet
  class Middleware

    def initialize(app)
      @app = app
    end

    def call(env)
      Rakismet.set_request_vars(env)
      response = @app.call(env)
      Rakismet.clear_request
      response
    end

  end
end

module Rakismet
  class Middleware

    def initialize(app)
      @app = app
    end

    def call(env)
      # set Rakismet.request vars...
      @app.call(env)
    end

  end
end

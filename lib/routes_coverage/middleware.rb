# frozen_string_literal: true

module RoutesCoverage
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(original_env)
      # router changes env/request during recognition so need a copy:
      env = original_env.dup
      req = ::Rails.application.routes.request_class.new(env)
      RoutesCoverage._touch_request(req)

      # TODO: detect 404s? and maybe other route errors?
      @app.call(original_env)
    end
  end
end

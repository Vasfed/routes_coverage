# frozen_string_literal: true

module RoutesCoverage
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(original_env)
      # router changes env/request during recognition so need a copy:
      env = original_env.dup
      req = ::Rails.application.routes.request_class.new env
      ::Rails.application.routes.router.recognize(req) do |route, parameters5, parameters4|
        parameters = parameters5 || parameters4
        dispatcher = route.app
        if dispatcher.respond_to?(:dispatcher?)
          req.path_parameters = parameters
          dispatcher = nil unless dispatcher.matches?(req) # && dispatcher.dispatcher?
        else # rails < 4.2
          dispatcher = route.app
          req.env['action_dispatch.request.path_parameters'] =
            (env['action_dispatch.request.path_parameters'] || {}).merge(parameters)
          while dispatcher.is_a?(ActionDispatch::Routing::Mapper::Constraints)
            dispatcher = (dispatcher.app if dispatcher.matches?(env))
          end
        end
        next unless dispatcher

        RoutesCoverage._touch_route(route)
        # there may be multiple matching routes - we should match only first
        break
      end
      # TODO: detect 404s? and maybe other route errors?
      @app.call(original_env)
    end
  end
end

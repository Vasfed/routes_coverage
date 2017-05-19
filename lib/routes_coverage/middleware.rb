module RoutesCoverage
  class Middleware
    def initialize app
      @app = app
    end

    def call env
      req = ::Rails.application.routes.request_class.new env
      ::Rails.application.routes.router.recognize(req) do |route|
        dispatcher = route.app
        if dispatcher.respond_to?(:dispatcher?)
          dispatcher = nil unless dispatcher.matches?(req) && dispatcher.dispatcher?
        else # rails < 4.2
          dispatcher = route.app
          while dispatcher.is_a?(ActionDispatch::Routing::Mapper::Constraints) do
            if dispatcher.matches?(env)
              dispatcher = dispatcher.app
            else
              dispatcher = nil
            end
          end
        end
        next unless dispatcher

        RoutesCoverage._touch_route(route)
        # there may be multiple matching routes - we should match only first
        break
      end
      #TODO: detect 404s? and maybe other route errors?
      @app.call(env)
    end
  end
end

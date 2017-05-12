module RoutesCoverage
  class Middleware
    def initialize app
      @app = app
    end

    def call env
      req = ::Rails.application.routes.request_class.new env
      ::Rails.application.routes.router.recognize(req) do |route|
        RoutesCoverage._touch_route(route)
      end
      #TODO: detect 404s? and maybe other route errors?
      @app.call(env)
    end
  end
end

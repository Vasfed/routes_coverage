module RoutesCoverage
  class Middleware
    def initialize app
      @app = app
    end

    def call env
      # method = env["REQUEST_METHOD"]
      # path = env["REQUEST_PATH"] || env["PATH_INFO"] || env["ORIGINAL_FULLPATH"]
      # puts "req #{method} #{env["REQUEST_PATH"]} || #{env["ORIGINAL_FULLPATH"]} || #{env["PATH_INFO"]}"
      # puts "env is #{env.inspect}"
      req = ::Rails.application.routes.request_class.new env
      ::Rails.application.routes.router.recognize(req) do |route|
        RoutesCoverage.current_result.touch_route(route)
      end
      #TODO: detect 404s? and maybe other route errors?
      @app.call(env)
    end
  end
end

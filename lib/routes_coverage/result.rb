module RoutesCoverage
  class Result
    def initialize
      @route_hits = Hash.new(0)
    end

    attr_reader :route_hits

    def touch_route route
      @route_hits[route] += 1
    end

    def all_routes
      ::Rails.application.routes.routes.routes
    end

    def expected_routes
      return @expected_routes if @expected_routes

      routes = all_routes.dup

      if defined?(::Sprockets) && defined?(::Sprockets::Environment)
        routes.reject!{|r| r.app.is_a?(::Sprockets::Environment) }
      end

      excluded_routes = []
      regex = Regexp.union(RoutesCoverage.settings.exclude_patterns)
      routes.reject!{|r|
        if "#{r.verb.to_s[8..-3]} #{r.path.spec}".strip =~ regex
          excluded_routes << r
        end
      }

      namespaces_regex = Regexp.union(RoutesCoverage.settings.exclude_namespaces.map{|n| /^\/#{n}/})
      routes.reject!{|r|
        if r.path.spec.to_s =~ namespaces_regex
          excluded_routes << r
        end
      }

      @excluded_routes = excluded_routes
      @expected_routes = routes
    end

    def pending_routes
      expected_routes - hit_routes
    end

    def excluded_routes
      expected_routes
      @excluded_routes
    end

    def hit_routes
      #TODO: sort?
      route_hits.keys
    end


    def hit_routes_count
      route_hits.size
    end

    def expected_routes_count
      expected_routes.size
    end

    def excluded_routes_count
      excluded_routes.size
    end

    def total_count
      all_routes.size
    end

    def coverage
      return 'n/a' unless expected_routes.any?
      (hit_routes_count * 100.0 / expected_routes_count).round(RoutesCoverage.settings.round_precision)
    end

    def avg_hits
      (route_hits.values.sum.to_f / hit_routes_count).round(RoutesCoverage.settings.round_precision)
    end

    def coverage_pass?
      coverage >= RoutesCoverage.settings.minimum_coverage
    end
  end
end

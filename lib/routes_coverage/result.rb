module RoutesCoverage
  class Result
    def initialize all_routes, hit_routes, settings
      @all_routes = all_routes
      @route_hit_counts = hit_routes
      @settings = settings
    end

    attr_reader :all_routes

    attr_reader :route_hit_counts

    def expected_routes
      return @expected_routes if @expected_routes

      routes = all_routes.dup

      if defined?(::Sprockets) && defined?(::Sprockets::Environment)
        routes.reject!{|r| r.app.is_a?(::Sprockets::Environment) }
      end

      excluded_routes = []
      regex = Regexp.union(@settings.exclude_patterns)
      routes.reject!{|r|
        if "#{r.verb.to_s[8..-3]} #{r.path.spec}".strip =~ regex
          excluded_routes << r
        end
      }

      namespaces_regex = Regexp.union(@settings.exclude_namespaces.map{|n| /^\/#{n}/})
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
      @route_hit_counts.keys
    end


    def hit_routes_count
      @route_hit_counts.size
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
      (hit_routes_count * 100.0 / expected_routes_count).round(@settings.round_precision)
    end

    def avg_hits
      (@route_hit_counts.values.sum.to_f / hit_routes_count).round(@settings.round_precision)
    end

    def coverage_pass?
      !@settings.minimum_coverage || (coverage >= @settings.minimum_coverage)
    end
  end
end

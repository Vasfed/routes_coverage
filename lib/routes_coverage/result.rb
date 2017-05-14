require 'active_support/core_ext/string' # needed for rails5 version of inspector
require 'action_dispatch/routing/inspector'

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

      filter_regex = Regexp.union(@settings.exclude_patterns)
      namespaces_regex = Regexp.union(@settings.exclude_namespaces.map{|n| /^\/#{n}/})

      routes_groups = all_routes.group_by{|r|
        !!(
          ("#{r.verb.to_s[8..-3]} #{r.path.spec}".strip =~ filter_regex) ||
          (r.path.spec.to_s =~ namespaces_regex)
        )
      }

      @excluded_routes = routes_groups[true] || []
      @expected_routes = routes_groups[false] || []
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
      !@settings.minimum_coverage || (coverage.to_f >= @settings.minimum_coverage)
    end

    def all_routes_with_hits
      res = Inspector.new(all_routes).collect_all_routes
      res.each{|val|
        val[:hits] = @route_hit_counts[val[:original]] || 0
      }
      res
    end

    class Inspector < ActionDispatch::Routing::RoutesInspector
      def collect_all_routes
        res = collect_routes(@routes)
        #TODO: test with engines
        @engines.each do |engine_name, engine_routes|
          res += engine_routes.map{|er|
            er.merge({ engine_name: engine_name })
          }
        end
        res
      end

      def collect_routes(routes)
        routes.collect do |route|
          ActionDispatch::Routing::RouteWrapper.new(route)
        end.reject do |route|
          route.internal?
        end.collect do |route|
          collect_engine_routes(route)

          { name:   route.name,
            verb:   route.verb,
            path:   route.path,
            reqs:   route.reqs,
            # regexp: route.json_regexp, # removed, this is not present in rails5
            # added:
            original: route,
          }
        end
      end
    end

  end
end

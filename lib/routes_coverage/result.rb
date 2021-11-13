require 'active_support/core_ext/string' # needed for rails5 version of inspector

module RoutesCoverage
  class Result
    begin
      require 'action_dispatch/routing/inspector'
      class Inspector < ActionDispatch::Routing::RoutesInspector
        NEW_RAILS = true
        def collect_all_routes
          res = collect_routes(@routes)
          # TODO: test with engines
          @engines.each do |engine_name, engine_routes|
            res += engine_routes.map  do |er|
              er.merge({ engine_name: engine_name })
            end
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

            { name: route.name,
              verb: route.verb,
              path: route.path,
              reqs: route.reqs,
              # regexp: route.json_regexp, # removed, this is not present in rails5
              # added:
              original: route }
          end
        end
      end
    rescue LoadError
      # rails 3
      require 'rails/application/route_inspector'
      class Inspector < Rails::Application::RouteInspector
        NEW_RAILS = false
        def collect_all_routes(routes)
          res = collect_routes(routes)
          @engines.each do |engine_name, engine_routes|
            res += engine_routes.map  do |er|
              er.merge({ engine_name: engine_name })
            end
          end
          res
        end

        def collect_routes(routes)
          routes = routes.collect do |route|
            route_reqs = route.requirements

            rack_app = discover_rack_app(route.app)

            controller = route_reqs[:controller] || ':controller'
            action     = route_reqs[:action]     || ':action'

            endpoint = rack_app ? rack_app.inspect : "#{controller}##{action}"
            constraints = route_reqs.except(:controller, :action)

            reqs = endpoint
            reqs += " #{constraints.inspect}" unless constraints.empty?

            collect_engine_routes(reqs, rack_app)

            { name: route.name.to_s,
              verb: route.verb.source.gsub(/[$^]/, ''),
              path: route.path.spec.to_s,
              reqs: reqs,
              # added:
              original: route }
          end

          # Skip the route if it's internal info route
          routes.reject { |r| r[:path] =~ %r{/rails/info/properties|^#{Rails.application.config.assets.prefix}} }
        end
      end
    end

    def initialize(all_routes, hit_routes, settings)
      @all_routes = all_routes
      @route_hit_counts = hit_routes
      @settings = settings
    end

    attr_reader :all_routes, :route_hit_counts

    def expected_routes
      return @expected_routes if @expected_routes

      filter_regex = Regexp.union(@settings.exclude_patterns)
      namespaces_regex = Regexp.union(@settings.exclude_namespaces.map { |n| %r{^/#{n}} })

      routes_groups = all_routes.group_by do |r|
        !!(
          ("#{r.verb.to_s[8..-3]} #{r.path.spec}".strip =~ filter_regex) ||
          (r.path.spec.to_s =~ namespaces_regex)
        )
      end

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
      # TODO: sort?
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
      return 0 unless expected_routes.any?

      (hit_routes_count * 100.0 / expected_routes_count).round(@settings.round_precision)
    end

    def avg_hits
      (@route_hit_counts.values.sum.to_f / hit_routes_count).round(@settings.round_precision)
    end

    def coverage_pass?
      !@settings.minimum_coverage || (coverage.to_f >= @settings.minimum_coverage)
    end

    def all_routes_with_hits
      res = if Inspector::NEW_RAILS
              Inspector.new(all_routes).collect_all_routes
            else
              Inspector.new.collect_all_routes(all_routes)
            end
      res.each do |val|
        val[:hits] = @route_hit_counts[val[:original]] || 0
      end
      res
    end
  end
end

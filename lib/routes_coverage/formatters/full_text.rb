require 'action_dispatch/routing/inspector'

module RoutesCoverage
  module Formatters
    class FullText < SummaryText

      class Inspector < ActionDispatch::Routing::RoutesInspector
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
              regexp: route.json_regexp,
              original: route, # added
            }
          end
        end
      end

      class RouteFormatter < ActionDispatch::Routing::ConsoleFormatter

        def initialize result=nil, _settings=nil, output_hits=false
          @result = result
          @output_hits = output_hits
          @output_prefix = false
          super()
        end

        def no_routes
          @buffer << "\tNone"
        end

        private
        HEADER = ['Prefix', 'Verb', 'URI Pattern', 'Controller#Action']
        def draw_section(routes)
          header_lengths = HEADER.map(&:length)
          name_width, verb_width, path_width, reqs_width = widths(routes).zip(header_lengths).map(&:max)

          hits = nil
          routes.map do |r|
            # puts "route is #{r.inspect}"
            if @output_hits
              # hits = " ?"
              original_route = r[:original].__getobj__ # SimpleDelegator
              hits = " #{@result.route_hits[original_route]}"
            end
            "#{r[:name].rjust(name_width) if @output_prefix} #{r[:verb].ljust(verb_width)} #{r[:path].ljust(path_width)} #{r[:reqs].ljust(reqs_width)}#{hits}"
          end
        end

        def draw_header(routes)
          name_width, verb_width, path_width, reqs_width = widths(routes)

          "#{"Prefix".rjust(name_width) if @output_prefix} #{"Verb".ljust(verb_width)} #{"URI Pattern".ljust(path_width)} #{"Controller#Action".ljust(reqs_width)}#{' Hits' if @output_hits}"
        end

        def widths(routes)
          [routes.map { |r| r[:name].length }.max || 0,
           routes.map { |r| r[:verb].length }.max || 0,
           routes.map { |r| r[:path].length }.max || 0,
           routes.map { |r| r[:reqs].length }.max || 0,
         ]
        end
      end

      def hit_routes
        routes = result.hit_routes

        # verb_width = routes.map{ |r| r[:verb].length }.max
        # path_width = routes.map{ |r| r[:path].length }.max

        [
          "Covered routes:",
          # "#{"Verb".ljust(verb_width)} #{"Path".ljust(path_width)} Reqs",
          # routes.map do |r|
          #   "#{r.verb.ljust(verb_width)} #{r.path.ljust(path_width)} #{r.reqs}"
          # end
          Inspector.new(routes).format(RouteFormatter.new(result, settings, true)),
          nil,
          "Pending routes:",
          Inspector.new(result.pending_routes).format(RouteFormatter.new),
        ].flatten.join("\n")
      end

      def format
        "\nRoutes coverage is #{result.coverage}% (#{hits_count})#{status}\n\n#{hit_routes}"
      end
    end
  end
end

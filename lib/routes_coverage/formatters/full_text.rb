require 'action_dispatch/routing/inspector'

module RoutesCoverage
  module Formatters
    class FullText < SummaryText

      class RouteFormatter < ActionDispatch::Routing::ConsoleFormatter
        def no_routes
          @buffer << "\tNone"
        end

        private
        HEADER = ['Prefix', 'Verb', 'URI Pattern', 'Controller#Action']
        def draw_section(routes)
          header_lengths = HEADER.map(&:length)
          name_width, verb_width, path_width, reqs_width = widths(routes).zip(header_lengths).map(&:max)

          routes.map do |r|
            "#{r[:name].rjust(name_width)} #{r[:verb].ljust(verb_width)} #{r[:path].ljust(path_width)} #{r[:reqs].ljust(reqs_width)} ?"
          end
        end

        def draw_header(routes)
          name_width, verb_width, path_width, reqs_width = widths(routes)

          "#{"Prefix".rjust(name_width)} #{"Verb".ljust(verb_width)} #{"URI Pattern".ljust(path_width)} #{"Controller#Action".ljust(reqs_width)} Hits"
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
          ActionDispatch::Routing::RoutesInspector.new(routes).format(RouteFormatter.new),
          nil,
          "Pending routes:",
          ActionDispatch::Routing::RoutesInspector.new(result.pending_routes).format(RouteFormatter.new),
        ].flatten.join("\n")
      end

      def format
        "\nRoutes coverage is #{result.coverage}% (#{hits_count})#{status}\n\n#{hit_routes}"
      end
    end
  end
end

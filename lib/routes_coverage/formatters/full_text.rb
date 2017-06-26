module RoutesCoverage
  module Formatters
    class FullText < SummaryText

      class RouteFormatter
        attr_reader :buffer

        def initialize result=nil, _settings=nil, output_hits=false
          @buffer = []
          @result = result
          @output_hits = output_hits
          @output_prefix = false
        end

        def result
          @buffer.join("\n")
        end

        def section_title(title)
          @buffer << "\n#{title}:"
        end

        def section(routes)
          @buffer << draw_section(routes)
        end

        def header(routes)
          @buffer << draw_header(routes)
        end

        def no_routes _routes_from_rails5=nil
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
              if r[:original].respond_to?(:__getobj__)
                original_route = r[:original].__getobj__ # SimpleDelegator
              else
                original_route = r[:original]
              end
              hits = " #{@result.route_hit_counts[original_route]}"
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


      def routes_section formatter, title, routes
        formatter.buffer << title

        if routes.none?
          formatter.no_routes
        else
          formatter.header routes
          formatter.section routes
        end

        formatter.result
      end

      def hit_routes
        routes = result.hit_routes
        # engine routes now are in the same list
        if Result::Inspector::NEW_RAILS
          hit_routes = Result::Inspector.new(result.hit_routes).collect_all_routes
          pending_routes = Result::Inspector.new(result.pending_routes).collect_all_routes
        else
          #rails 3
          hit_routes = Result::Inspector.new.collect_all_routes(result.hit_routes)
          pending_routes = Result::Inspector.new.collect_all_routes(result.pending_routes)
        end

        return routes_section(RouteFormatter.new(result, settings, true), "Covered routes:", hit_routes) + "\n\n" +
        routes_section(RouteFormatter.new(result, settings), "Pending routes:", pending_routes)
      end

      def format
        "#{super}\n\n#{hit_routes}"
      end
    end
  end
end

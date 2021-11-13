# frozen_string_literal: true

module RoutesCoverage
  module Formatters
    class FullText < SummaryText
      class RouteFormatter
        attr_reader :buffer

        def initialize(result = nil, _settings = nil, output_hits = false)
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

        def no_routes(_routes_from_rails5 = nil)
          @buffer << "\tNone"
        end

        private

        HEADER = ['Prefix', 'Verb', 'URI Pattern', 'Controller#Action'].freeze
        def draw_section(routes)
          header_lengths = HEADER.map(&:length)
          name_width, verb_width, path_width, reqs_width = widths(routes).zip(header_lengths).map(&:max)

          routes.map do |r|
            # unwrap SimpleDelegator
            original_route = r[:original].respond_to?(:__getobj__) ? r[:original].__getobj__ : r[:original]

            "#{r[:name].rjust(name_width) if @output_prefix} "\
              "#{r[:verb].ljust(verb_width)} #{r[:path].ljust(path_width)} #{r[:reqs].ljust(reqs_width)}"\
              "#{" #{@result.route_hit_counts[original_route]}" if @output_hits}"
          end
        end

        def draw_header(routes)
          name_width, verb_width, path_width, reqs_width = widths(routes)

          [
            ('Prefix'.rjust(name_width) if @output_prefix),
            'Verb'.ljust(verb_width),
            'URI Pattern'.ljust(path_width),
            'Controller#Action'.ljust(reqs_width),
            ('Hits' if @output_hits)
          ].compact.join(' ')
        end

        def widths(routes)
          %i[name verb path reqs].map do |key|
            routes.map { |r| r[key].length }.max.to_i
          end
        end
      end

      def routes_section(formatter, title, routes)
        formatter.buffer << title

        if routes.none?
          formatter.no_routes
        else
          formatter.header routes
          formatter.section routes
        end

        formatter.result
      end

      def collect_routes(routes)
        # rails 3
        return Result::Inspector.new.collect_all_routes(routes) unless Result::Inspector::NEW_RAILS

        Result::Inspector.new(routes).collect_all_routes
      end

      def hit_routes_details
        # engine routes now are in the same list
        hit_routes = collect_routes(result.hit_routes)
        pending_routes = collect_routes(result.pending_routes)

        <<~TXT
          #{routes_section(RouteFormatter.new(result, settings, true), 'Covered routes:', hit_routes)}

          #{routes_section(RouteFormatter.new(result, settings), 'Pending routes:', pending_routes)}
        TXT
      end

      def format
        "#{super}\n\n#{hit_routes_details}"
      end
    end
  end
end

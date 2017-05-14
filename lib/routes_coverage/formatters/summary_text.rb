module RoutesCoverage
  module Formatters
    class SummaryText < Base
      def hits_count result
        "#{result.hit_routes_count} of #{result.expected_routes_count}#{"(#{result.total_count} total)" if result.expected_routes_count != result.total_count} routes hit#{ " at #{result.avg_hits} hits average" if result.hit_routes_count > 0}"
      end

      def status
        return unless settings.minimum_coverage
        unless result.coverage_pass?
          "Coverage is too low"
        end
      end

      def format
        buffer = [
          "Routes coverage is #{result.coverage}% (#{hits_count result})"
        ]

        if groups.any?
          buffer += groups.map{|group_name, group_result|
            "  #{group_name}: #{group_result.coverage}% (#{hits_count group_result})"
          }
        end

        buffer << status

        buffer.compact.join("\n")
      end
    end
  end
end

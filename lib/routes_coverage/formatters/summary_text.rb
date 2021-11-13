module RoutesCoverage
  module Formatters
    class SummaryText < Base
      def hits_count(result)
        "#{result.hit_routes_count} of #{result.expected_routes_count}#{if result.expected_routes_count != result.total_count
                                                                          "(#{result.total_count} total)"
                                                                        end} routes hit#{if result.hit_routes_count > 0
                                                                                           " at #{result.avg_hits} hits average"
                                                                                         end}"
      end

      def status
        return unless settings.minimum_coverage

        "Coverage is too low" unless result.coverage_pass?
      end

      def format
        buffer = [
          "Routes coverage is #{result.coverage}% (#{hits_count result})"
        ]

        if groups.any?
          buffer += groups.map do |group_name, group_result|
            "  #{group_name}: #{group_result.coverage}% (#{hits_count group_result})"
          end
        end

        buffer << status

        buffer.compact.join("\n")
      end
    end
  end
end

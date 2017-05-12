module RoutesCoverage
  module Formatters
    class SummaryText < Base
      def hits_count
        "#{result.hit_routes_count} of #{result.expected_routes_count}#{"(#{result.total_count} total)" if result.expected_routes_count != result.total_count} routes hit#{ " at #{result.avg_hits} hits average" if result.hit_routes_count > 0}"
      end

      def status
        return unless settings.minimum_coverage
        if result.coverage_pass?
          ""
        else
          "\nCoverage failed. Need at least #{(settings.minimum_coverage / 100.0 * result.total_count).ceil}"
        end
      end

      def format
        "Routes coverage is #{result.coverage}% (#{hits_count})#{status}"
      end
    end
  end
end

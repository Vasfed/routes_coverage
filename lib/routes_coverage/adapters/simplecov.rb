module RoutesCoverage
  module Adapters
    class SimpleCov
      def self.use
        RoutesCoverage.reset!
        ::SimpleCov.at_exit{
          RoutesCoverage.perform_report
        }
      end
    end
  end
end

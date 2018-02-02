require 'rspec/core'

RSpec.configure do |config|
  config.add_setting :routes_coverage
  config.routes_coverage = RoutesCoverage.settings
end

module RoutesCoverage
  module Adapters
    class RSpec
      def self.use
        ::RSpec.configure do |config|
          config.before(:suite) do
            RoutesCoverage.reset!
          end

          config.after(:suite) do
            RoutesCoverage.perform_report
          end
        end
      end
    end
  end
end

require 'rspec/core'

RSpec.configure do |config|
  config.add_setting :routes_coverage
  config.routes_coverage = RoutesCoverage.settings

  config.before(:suite) do
    RoutesCoverage.reset!
  end

  config.after(:suite) do
    RoutesCoverage.perform_report
  end
end

require "routes_coverage/version"
require "routes_coverage/result"
require "routes_coverage/middleware"

require "routes_coverage/formatters/summary_text"
require "routes_coverage/formatters/full_text"

module RoutesCoverage
  class Railtie < ::Rails::Railtie
    railtie_name :routes_coverage

    initializer "request_coverage.inject_test_middleware" do
      if RoutesCoverage.enabled?
        ::Rails.application.middleware.use RoutesCoverage::Middleware
      end
    end
  end

  class Settings
    attr_reader :exclude_patterns
    attr_reader :exclude_namespaces
    attr_accessor :minimum_coverage
    attr_accessor :round_precision

    attr_accessor :format

    def initialize
      @exclude_patterns = []
      @exclude_namespaces = []
      @minimum_coverage = 80
      @round_precision = 1
      @format = :summary_text
    end
  end

  def self.enabled?
    ::Rails.env.test?
  end

  def self.settings
    @@settings ||= Settings.new
  end

  def self.configure
    yield self.settings
  end

  mattr_reader :pid

  def self.reset!
    @@route_hit_count = Hash.new(0)
    @@pid = Process.pid
  end

  def self.perform_report
    result = Result.new(
      ::Rails.application.routes.routes.routes,
      @@route_hit_count,
      settings
    )

    formatter_class = case settings.format
    when :full_text
      Formatters::FullText
    when :summary_text
      Formatters::SummaryText
    else
      raise "Unknown formatter #{settings.format.inspect}"
    end

    formatter = formatter_class.new(result, settings)

    puts
    puts formatter.format
  end


  def self._touch_route route
    reset! unless @@route_hit_count
    @@route_hit_count[route] += 1
  end
end

if RoutesCoverage.enabled?
  if defined? RSpec
    require "routes_coverage/adapters/rspec"
  else
    require "routes_coverage/adapters/atexit"
    RoutesCoverage::Adapters::AtExit.use
  end
end

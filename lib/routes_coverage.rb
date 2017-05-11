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

  mattr_reader :current_result
  mattr_reader :pid

  def self.reset!
    @@current_result = Result.new
    @@pid = Process.pid
  end

  def self.perform_report
    result = current_result

    formatter_class = case settings.format
    when :full_text
      Formatters::FullText
    when :summary_text
      Formatters::SummaryText
    else
      raise "Unknown formatter #{settings.format.inspect}"
    end

    formatter = formatter_class.new(result, settings)
    puts formatter.format
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

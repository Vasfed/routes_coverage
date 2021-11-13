require "routes_coverage/version"
require "routes_coverage/result"
require "routes_coverage/middleware"

require "routes_coverage/formatters/base"
require "routes_coverage/formatters/summary_text"
require "routes_coverage/formatters/full_text"
require "routes_coverage/formatters/html"

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
    attr_accessor :exclude_put_fallbacks

    attr_accessor :perform_report
    attr_accessor :minimum_coverage
    attr_accessor :round_precision

    attr_accessor :format

    attr_reader :groups

    def initialize
      @exclude_patterns = []
      @exclude_namespaces = []
      @exclude_put_fallbacks = false
      @minimum_coverage = 1
      @round_precision = 1
      @format = :html
      @groups = {}
      @perform_report = true
    end

    def formatter_class
      case format
      when :full_text
        Formatters::FullText
      when :summary_text
        Formatters::SummaryText
      when :html, :simplecov_html
        Formatters::Html
      when Formatters::Base
        format
      else
        raise "Unknown formatter #{settings.format.inspect}"
      end
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
    return unless settings.perform_report

    all_routes = ::Rails.application.routes.routes.routes.dup

    if defined?(::Sprockets) && defined?(::Sprockets::Environment)
      all_routes.reject!{|r| r.app.is_a?(::Sprockets::Environment) }
    end

    if settings.exclude_put_fallbacks
      all_routes.reject!{|put_route|
        (
          put_route.verb == /^PUT$/ ||
          put_route.verb == "PUT" # rails 5
        ) &&
        put_route.name.nil? &&
        @@route_hit_count[put_route] == 0 &&
        all_routes.any?{|patch_route|
          (
            patch_route.verb == /^PATCH$/ ||
            patch_route.verb == "PATCH" # rails5
          ) &&
          patch_route.defaults == put_route.defaults &&
          patch_route.ip == put_route.ip &&
          patch_route.path.spec.to_s == put_route.path.spec.to_s
        }
      }
    end

    all_result = Result.new(
      all_routes,
      @@route_hit_count,
      settings
    )


    groups = Hash[settings.groups.map{|group_name, matcher|
      group_routes = all_routes.select do |route|
        if matcher.respond_to?(:call)
          matcher.call(route)
        elsif matcher.is_a?(Hash)
          matcher.all? do |key, value|
            if key == :path
              route.path.spec.to_s =~ value
            elsif key == :constraints
              value.all? do |constraint_name, constraint_value|
                constraint_value.present? ?
                  route.constraints[constraint_name]&.match?(constraint_value) :
                  route.constraints[constraint_name].blank?
              end
            end
          end
        else
          route.path.spec.to_s.match?(matcher)
        end
      end

      [group_name,
        Result.new(
          group_routes,
          @@route_hit_count.slice(group_routes),
          settings
        )
      ]
    }]

    if groups.size > 1
      ungroupped_routes = all_routes.reject{|r|
        groups.values.any?{|group_routes|
          group_routes.all_routes.include? r
        }
      }

      if ungroupped_routes.any?
        groups["Ungroupped"] = Result.new(
          ungroupped_routes,
          @@route_hit_count.slice(ungroupped_routes),
          settings
        )
      end
    end

    puts
    puts settings.formatter_class.new(all_result, groups, settings).format
  end


  def self._touch_route route
    reset! unless @@route_hit_count
    @@route_hit_count[route] += 1
  end
end

if defined? RSpec
  require "routes_coverage/adapters/rspec"
end

if RoutesCoverage.enabled?
  if defined?(SimpleCov) && SimpleCov.running
    require 'routes_coverage/adapters/simplecov'
    RoutesCoverage::Adapters::SimpleCov.use
  elsif defined? RSpec
    RoutesCoverage::Adapters::RSpec.use
  else
    require "routes_coverage/adapters/atexit"
    RoutesCoverage::Adapters::AtExit.use
  end
end

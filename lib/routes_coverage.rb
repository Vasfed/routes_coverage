# frozen_string_literal: true

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
      ::Rails.application.middleware.use RoutesCoverage::Middleware if RoutesCoverage.enabled?
    end
  end

  class Settings
    attr_reader :exclude_patterns, :exclude_namespaces, :groups
    attr_accessor :exclude_put_fallbacks, :perform_report, :minimum_coverage, :round_precision, :format

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
    yield settings
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
      all_routes.reject! { |r| r.app.is_a?(::Sprockets::Environment) }
    end

    if settings.exclude_put_fallbacks
      all_routes.reject! do |put_route|
        (
          put_route.verb == /^PUT$/ ||
          put_route.verb == "PUT" # rails 5
        ) &&
          put_route.name.nil? &&
          @@route_hit_count[put_route] == 0 &&
          all_routes.any? do |patch_route|
            (
              patch_route.verb == /^PATCH$/ ||
              patch_route.verb == "PATCH" # rails5
            ) &&
              patch_route.defaults == put_route.defaults &&
              patch_route.ip == put_route.ip &&
              patch_route.path.spec.to_s == put_route.path.spec.to_s
          end
      end
    end

    all_result = Result.new(
      all_routes,
      @@route_hit_count,
      settings
    )

    groups = settings.groups.map do |group_name, matcher|
      group_routes = all_routes.select do |route|
        if matcher.respond_to?(:call)
          matcher.call(route)
        elsif matcher.is_a?(Hash)
          matcher.all? do |key, value|
            if key == :path
              route.path.spec.to_s =~ value
            elsif key == :constraints
              value.all? do |constraint_name, constraint_value|
                if constraint_value.present?
                  route.constraints[constraint_name]&.match?(constraint_value)
                else
                  route.constraints[constraint_name].blank?
                end
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
       )]
    end.to_h

    if groups.size > 1
      ungroupped_routes = all_routes.reject do |r|
        groups.values.any? do |group_routes|
          group_routes.all_routes.include? r
        end
      end

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

  def self._touch_route(route)
    reset! unless @@route_hit_count
    @@route_hit_count[route] += 1
  end
end

require "routes_coverage/adapters/rspec" if defined? RSpec

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

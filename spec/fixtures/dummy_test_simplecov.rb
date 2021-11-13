# frozen_string_literal: true

require 'simplecov'

SimpleCov.command_name("minitest")
SimpleCov.start

require_relative 'dummy_test'

RoutesCoverage.configure do |config|
  config.format = :simplecov_html
  config.groups["Some group"] = %r{^/somespace/}
  config.groups["Foo"] = %r{^/reqs/}
end

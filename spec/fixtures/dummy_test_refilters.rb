# frozen_string_literal: true

require_relative 'dummy_test'

RoutesCoverage.configure do |config|
  config.format = :full_text
  config.exclude_patterns << /index/
  config.exclude_patterns << %r{PATCH /reqs}
end

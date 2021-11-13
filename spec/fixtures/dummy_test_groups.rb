# frozen_string_literal: true

require_relative 'dummy_test'

RoutesCoverage.configure do |config|
  config.format = :full_text
  config.groups["Some group"] = %r{^/somespace/}
  config.groups["Foo"] = %r{^/reqs/}
  config.groups["Subdomain"] = { constraints: { subdomain: 'subdomain' } }
  config.groups["Controller"] = { controller: 'dummy', action: /\Aupdat/ }
end

# frozen_string_literal: true

require_relative 'dummy_test'

RoutesCoverage.configure do |config|
  config.format = :full_text
  config.groups["Some group"] = %r{^/somespace/}
  config.groups["Foo"] = %r{^/reqs/} # not `/reqs`
  config.groups["Subdomain"] = { constraints: { subdomain: 'subdomain' } }
  config.groups["Controller"] = { controller: 'dummy', action: /\Aupdat/ }

  # to get similar routes count on rails 3/4/5
  config.exclude_patterns << %r{PATCH\s+/reqs}
end

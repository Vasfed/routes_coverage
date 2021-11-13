require_relative 'dummy_test'

RoutesCoverage.configure do |config|
  config.format = :full_text
  config.groups["Some group"] = %r{^/somespace/}
  config.groups["Foo"] = %r{^/reqs/}
  config.groups["Subdomain"] = { constraints: { subdomain: 'subdomain' } }
end

require_relative 'dummy_test'


RoutesCoverage.configure do |config|
  config.format = :html
  config.exclude_put_fallbacks = true
  config.groups["Some group"] = %r{^/somespace/}
  config.groups["Foo"] = %r{^/reqs/}
  config.groups["EmptyGroup"] = %r{^/___empty___/}
end

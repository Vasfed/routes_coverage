RSpec.configure do |config|
  config.add_setting :routes_coverage
  config.routes_coverage = RoutesCoverage.settings

  config.before(:suite) do
    RoutesCoverage.reset!
  end

  config.after(:suite) do
    RoutesCoverage.perform_report
  end
end

# RSpec::RoutesCoverage.initialize_routes!
#
#
# if ENV['LIST_ROUTES_COVERAGE']
#   # require 'action_dispatch/routing/inspector'
#
#   format_routes = ->(routes){
#     formatter = ActionDispatch::Routing::ConsoleFormatter.new
#     ActionDispatch::Routing::RoutesInspector.new(routes).format(formatter)
#   }
#
#   # inspector = begin
#   #   require 'rails/application/route_inspector'
#   #   Rails::Application::RouteInspector
#   # rescue LoadError
#   #   require 'action_dispatch/routing/inspector'
#   #   ActionDispatch::Routing::RoutesInspector
#   # end.new
#
#   # inspector.instance_eval do
#   #   def formatted_routes(routes)
#   #     verb_width = routes.map{ |r| r[:verb].length }.max
#   #     path_width = routes.map{ |r| r[:path].length }.max
#
#   #     routes.map do |r|
#   #       "#{r[:verb].ljust(verb_width)} #{r[:path].ljust(path_width)} #{r[:reqs]}"
#   #     end
#   #   end
#   # end
#
#
#   legend = {
#     magenta: :excluded_routes,
#     green:   :manually_tested_routes,
#     blue:    :auto_tested_routes,
#     yellow:  :pending_routes
#   }
#
#   legend.each do |color, name|
#     total = name == :excluded_routes ? RSpec::RoutesCoverage.routes_num : RSpec::RoutesCoverage.tested_routes_num
#
#     puts "\n\n"
#     puts "#{name.to_s.humanize} (#{RSpec::RoutesCoverage.send(name).length}/#{total})".send(color).bold
#     puts "\n"
#     # format_routes.call(RSpec::RoutesCoverage.send(name)).each do |route|
#     #   puts '  ' + route.send(color)
#     # end
#     routes = RSpec::RoutesCoverage.send(name)
#     if routes.any?
#       puts format_routes.call(routes).send(color)
#     end
#   end
# else
#   puts  "\n\n"
#   puts  'Routes coverage stats:'
#   puts  "   Routes to test: #{RSpec::RoutesCoverage.tested_routes_num}/#{RSpec::RoutesCoverage.routes_num}".magenta
#   puts  "  Manually tested: #{RSpec::RoutesCoverage.manually_tested_routes.length}/#{RSpec::RoutesCoverage.tested_routes_num}".green
#   puts  "      Auto tested: #{RSpec::RoutesCoverage.auto_tested_routes.length}/#{RSpec::RoutesCoverage.tested_routes_num}".blue
#   print "          Pending: #{RSpec::RoutesCoverage.pending_routes.length}/#{RSpec::RoutesCoverage.tested_routes_num}".yellow
# end

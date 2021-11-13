# frozen_string_literal: true

require 'bundler'
require 'bundler/setup'
require 'bundler/gem_tasks'

require 'rake/testtask'

Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.libs.push 'spec'
end

Rake::TestTask.new(:dummytest) { |t| t.pattern = 'spec/fixtures/dummy_test.rb' }
Rake::TestTask.new(:dummytest_html) { |t| t.pattern = 'spec/fixtures/dummy_html.rb' }
Rake::TestTask.new(:dummytest_full) { |t| t.pattern = 'spec/fixtures/dummy_test_full.rb' }
Rake::TestTask.new(:dummytest_filter) { |t| t.pattern = 'spec/fixtures/dummy_test_nsfilters.rb' }
Rake::TestTask.new(:dummytest_groups) { |t| t.pattern = 'spec/fixtures/dummy_test_groups.rb' }

task default: :spec

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'routes_coverage/version'

namespace :assets do
  desc 'Compiles all assets'
  task :compile do
    puts 'Compiling assets'
    require 'sprockets'
    assets = Sprockets::Environment.new
    assets.append_path 'assets/javascripts'
    assets.append_path 'assets/stylesheets'
    compiled_path = 'compiled_assets'
    assets['application.js'].write_to("#{compiled_path}/routes.js")
    assets['application.css'].write_to("#{compiled_path}/routes.css")
  end
end

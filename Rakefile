require 'bundler'
require 'bundler/setup'
require "bundler/gem_tasks"

require 'rake/testtask'

Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.libs.push 'spec'
end

Rake::TestTask.new(:dummytest) do |t| t.pattern = 'spec/fixtures/dummy_test.rb' end
Rake::TestTask.new(:dummytest_html) do |t| t.pattern = 'spec/fixtures/dummy_html.rb' end
Rake::TestTask.new(:dummytest_full) do |t| t.pattern = 'spec/fixtures/dummy_test_full.rb' end
Rake::TestTask.new(:dummytest_filter) do |t| t.pattern = 'spec/fixtures/dummy_test_nsfilters.rb' end
Rake::TestTask.new(:dummytest_groups) do |t| t.pattern = 'spec/fixtures/dummy_test_groups.rb' end


task :default => :spec

$:.push File.expand_path("../lib", __FILE__)
require 'routes_coverage/version'

namespace :assets do
  desc "Compiles all assets"
  task :compile do
    puts "Compiling assets"
    require "sprockets"
    assets = Sprockets::Environment.new
    assets.append_path "assets/javascripts"
    assets.append_path "assets/stylesheets"
    compiled_path = "compiled_assets"
    assets["application.js"].write_to("#{compiled_path}/routes.js")
    assets["application.css"].write_to("#{compiled_path}/routes.css")
  end
end

require 'bundler'
require 'bundler/setup'
require "bundler/gem_tasks"

require 'rake/testtask'

Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.libs.push 'spec'
end

Rake::TestTask.new(:dummytest) do |t| t.pattern = 'spec/fixtures/dummy_test.rb' end
Rake::TestTask.new(:dummytest_full) do |t| t.pattern = 'spec/fixtures/dummy_test_full.rb' end
Rake::TestTask.new(:dummytest_filter) do |t| t.pattern = 'spec/fixtures/dummy_test_nsfilters.rb' end
Rake::TestTask.new(:dummytest_groups) do |t| t.pattern = 'spec/fixtures/dummy_test_groups.rb' end


task :default => :spec

$:.push File.expand_path("../lib", __FILE__)
require 'routes_coverage/version'

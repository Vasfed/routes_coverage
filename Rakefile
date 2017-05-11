require 'bundler'
require 'bundler/setup'
require "bundler/gem_tasks"

require 'rake/testtask'

Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.libs.push 'spec'
end

task :default => :spec

$:.push File.expand_path("../lib", __FILE__)
require 'routes_coverage/version'

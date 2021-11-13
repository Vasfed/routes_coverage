# frozen_string_literal: true

source 'https://rubygems.org'

# NB: gem's dependencies are in routes_coverage.gemspec
# NB: all other non-listed gems should go into Appraisals,
# this file is only for quick tests

unless defined?(Appraisal)
  # rails should be included before us
  gem 'rails', '~>5.2.6'
  gem 'simplecov', require: false

  gem 'm', require: false # minitest runner with support for runing one test by source location
  gem 'rubocop', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rake', require: false

  # for assets:
  gem 'sprockets'
  gem 'sass'
end

gemspec

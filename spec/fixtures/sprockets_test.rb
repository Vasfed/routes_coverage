# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
require 'rails'
require 'sprockets/rails'
require 'routes_coverage'

require 'minitest/autorun'

class DummyApplication < Rails::Application
  config.root = File.expand_path('.', __dir__)
  config.eager_load = false
  config.secret_token = 'df5394d6c6fa8fdc95cf883df725b8b8' unless Rails.version >= '5'
  config.secret_key_base = 'df5394d6c6fa8fdc95cf883df725b8b6'
  config.active_support.test_order = :sorted

  config.assets.compile = true
  config.assets.paths << File.dirname(__FILE__)
  config.assets.precompile << 'sprockets_test.js'

  config.action_dispatch.show_exceptions = false # raise instead
end

DummyApplication.initialize!
DummyApplication.routes.draw do
  resources :reqs, only: [:index], controller: :dummy
end

class DummyRequestTest < ActionDispatch::IntegrationTest
  def test_coverage_enabled
    assert(RoutesCoverage.enabled?)
  end

  def test_index
    get '/assets/sprockets_test.js?body=1'
    assert_response :success
  end
end


ENV['RAILS_ENV'] = 'test'

require 'rails'
require "action_controller/railtie"
require "routes_coverage"

#NB: at_exit order matters
require 'minitest/autorun'


RoutesCoverage.settings.format = :full_text

class DummyApplication < Rails::Application
  config.eager_load = false
  config.secret_token = 'df5394d6c6fa8fdc95cf883df725b8b8'
  config.secret_key_base = 'df5394d6c6fa8fdc95cf883df725b8b6'
end

class DummyController < ActionController::Base
  def current
    render text:'123'
  end

  def index
    render text:'123'
  end
end

DummyApplication.initialize!
DummyApplication.routes.draw do
  resources :reqs, controller: :dummy do
    post :current, on: :collection
  end
end

class DummyRequestTest < ActionDispatch::IntegrationTest
  def test_coverage_enabled
    assert_equal RoutesCoverage.enabled?, true
  end

  def test_index
    get '/reqs/'
    assert_response :success
  end

  def test_post
    post '/reqs/current'
    assert_response :success
  end

  def test_404
    get '/asfjdshfjsdh/'
    assert_response :not_found
  end
end

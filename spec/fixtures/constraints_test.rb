
ENV['RAILS_ENV'] = 'test'
require_relative 'dummy_app'
require 'minitest/autorun'

DummyApplication.routes.draw do
  get 'rec', to: 'dummy#index',
             constraints: -> (request) { request.params[:TYPE] == '1' },
             as: :route1
  get 'rec', to: 'dummy#update',
             constraints: -> (request) { request.params[:TYPE] == '2' },
             as: :route2
end

DummyApplication.config.action_dispatch.show_exceptions = false

RoutesCoverage.configure do|config|
  config.format = :full_text
end


class DummyRequestTest < ActionDispatch::IntegrationTest
  def test_coverage_enabled
    assert_equal RoutesCoverage.enabled?, true
  end

  def test_patch
    get '/rec?TYPE=1'
    assert_response :success
  end

  def test_put
    get '/rec?TYPE=2'
    assert_response :success
  end
end

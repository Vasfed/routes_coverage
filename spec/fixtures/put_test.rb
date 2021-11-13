# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
require_relative 'dummy_app'
require 'minitest/autorun'

DummyApplication.routes.draw do
  resources :reqs, only: [:update], controller: :dummy
  resources :used_put, only: [:update], controller: :dummy
  put :standalone_put, controller: :dummy, action: :update
end

RoutesCoverage.configure do |config|
  config.format = :full_text
  config.exclude_put_fallbacks = true
end

class DummyRequestTest < ActionDispatch::IntegrationTest
  def test_coverage_enabled
    assert(RoutesCoverage.enabled?)
  end

  def test_patch
    patch '/reqs/1'
    assert_response :success
  end

  def test_put
    put '/used_put/1'
    assert_response :success
  end
end

# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
require_relative 'dummy_routes'

# NB: at_exit order matters
require 'minitest/autorun'

RoutesCoverage.settings.format = :summary_text

class DummyRequestTest < ActionDispatch::IntegrationTest
  def test_coverage_enabled
    assert(RoutesCoverage.enabled?)
  end

  def test_index
    get '/reqs'
    assert_response :success
  end

  def test_post
    post '/reqs/current'
    assert_response :success
  end

  def test_not_found
    get '/asfjdshfjsdh'
    assert_response :not_found
  end
end

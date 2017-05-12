
ENV['RAILS_ENV'] = 'test'
require_relative 'dummy_app'

#NB: at_exit order matters
require 'minitest/autorun'

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

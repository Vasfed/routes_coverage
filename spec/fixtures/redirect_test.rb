
ENV['RAILS_ENV'] = 'test'
require_relative 'dummy_app'
require 'minitest/autorun'

DummyApplication.routes.draw do
  resources :reqs, only:[:index], controller: :dummy
  root to:redirect('/reqs')
end

RoutesCoverage.configure do|config|
  config.format = :full_text
end


class DummyRequestTest < ActionDispatch::IntegrationTest
  def test_coverage_enabled
    assert_equal RoutesCoverage.enabled?, true
  end

  def test_root_redirect
    get '/'
    assert_response :redirect
  end

end

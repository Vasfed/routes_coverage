
ENV['RAILS_ENV'] = 'test'
require_relative 'dummy_app'
require 'minitest/autorun'

class CustomConstraintsClass
  def self.matches?(request)
    # puts "req.params: #{request.params.inspect}"
    # puts "\t#{caller.select{|l| l =~ /routes/}.join("\n\t")}"
    request.params[:param1].present?
  end
end

DummyApplication.routes.draw do
  get 'rec', to: 'dummy#index', constraints: CustomConstraintsClass, as: :no_param
  get 'rec/:param1', to: 'dummy#index', constraints: CustomConstraintsClass, as: :one_param
  get 'rec/:param1/:param2', to: 'dummy#index', constraints: CustomConstraintsClass, as: :two_param
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
    get '/rec?param1=1'
    assert_response :success

    get '/rec/foo'
    assert_response :success

    # get '/rec/foo/ba_r'
    # assert_response :success
  end


end

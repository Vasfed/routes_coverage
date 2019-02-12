
ENV['RAILS_ENV'] = 'test'
require_relative 'dummy_app'
require 'minitest/autorun'


class NestedEngine < Rails::Engine
  # def self.routes
  #   @routes ||= ActionDispatch::Routing::RouteSet.new
  # end

  routes.draw do
    root to: "engine#index"
  end

  class Controller < ActionController::Base
    include NestedEngine.routes.url_helpers
  end
end

class EngineController < ActionController::Base
  def index
    render status: :ok, inline: 'lala'
  end
end

DummyApplication.routes.draw do
  root to: 'dummy#index'
  mount NestedEngine => "/engine/" 
end

DummyApplication.config.action_dispatch.show_exceptions = false

RoutesCoverage.configure do|config|
  config.format = :full_text
end


class EnginesTest < ActionDispatch::IntegrationTest
  def test_coverage_enabled
    assert_equal RoutesCoverage.enabled?, true
  end

  def test_patch
    get '/'
    assert_response :success

    get '/engine/'
    assert_response :success
  end

end

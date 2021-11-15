# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
require_relative 'dummy_routes'

# NB: at_exit order matters
require 'minitest/autorun'

RoutesCoverage.settings.format = :full_text
RoutesCoverage.settings.include_from_controller_tests = ENV['INFER_FROM_CONTROLLER'] == '1'

# ActionController::TestCase is deprecated in rails 5 in favour of ActionDispatch::IntegrationTest
# but main purpose of routes_coverage is raising test coverage in old apps prior to upgrade, so need to support it:
class DummyControllerTest < ActionController::TestCase
  include ActionController::TestCase::Behavior
  tests DummyController

  # in a non-fully initialized app this seems to be necessary:
  setup { @routes = Rails.application.routes }

  def test_index_working
    assert(RoutesCoverage.enabled?)
    get :index
    assert_response :success
  end
end

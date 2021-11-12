
require 'rails'
require "action_controller/railtie"
require "routes_coverage"

class DummyApplication < Rails::Application
  config.eager_load = false
  config.secret_token = 'df5394d6c6fa8fdc95cf883df725b8b8' unless Rails.version >= '5'
  config.secret_key_base = 'df5394d6c6fa8fdc95cf883df725b8b6'
  config.active_support.test_order = :sorted #if config.active_support.respond_to?(:test_order)

  config.active_support.deprecation = :stderr
  # config.action_dispatch.show_exceptions = false #raise instead
end

class DummyController < ActionController::Base
  def current
    render status: :ok, inline: 'lala'
  end

  def index
    render status: :ok, inline: 'lala'
  end

  def update
    render status: :ok, inline: 'lala'
  end
end

DummyApplication.initialize!

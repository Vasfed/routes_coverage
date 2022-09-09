# frozen_string_literal: true

require_relative 'dummy_app'
require 'routes_coverage/auditor'

DummyApplication.routes.draw do
  resources :reqs, only: %i[index update create], controller: :dummy do
    post :current, on: :collection
    get :some_custom
  end

  namespace :somespace do
    resources :foo, only: [:index]
  end

  namespace :otherspace do
    resources :bar, only: [:index]
  end

  resources :subdomain_route, only: [:index], constraints: { subdomain: 'subdomain' }

  get 'r*catch_almost_all_route', to: 'dummy#not_found_error'
end

RoutesCoverage::Auditor.new.print_missing_actions

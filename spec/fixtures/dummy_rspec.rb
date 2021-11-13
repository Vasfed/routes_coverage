# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
require_relative 'dummy_routes'
require 'rspec/rails'

RoutesCoverage.settings.format = :summary_text

RSpec.describe "dummy", type: :request do
  it "ensure coverage is enabled" do
    expect(RoutesCoverage.enabled?).to be_truthy
  end

  it "index" do
    get '/reqs/'
    expect(response.code).to eq '200'
    expect(response).to be_success
  end

  it "post" do
    post '/reqs/current'
    expect(response.code).to eq '200'
    expect(response).to be_success
  end

  it "404" do
    get '/asfjdshfjsdh/'
    expect(response.code).to eq '404'
  end
end

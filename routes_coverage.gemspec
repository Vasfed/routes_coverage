# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'routes_coverage/version'

Gem::Specification.new do |spec|
  spec.name          = "routes_coverage"
  spec.version       = RoutesCoverage::VERSION
  spec.authors       = ["Vasily Fedoseyev"]
  spec.email         = ["vasilyfedoseyev@gmail.com"]

  spec.summary       = "Provides coverage report for your rails routes"
  spec.description   = "Generates coverage report for routes hit by your request/integration/feature tests "\
                       "including capybara ones"
  spec.homepage      = "https://github.com/Vasfed/routes_coverage"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 2.0"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|assets|bin|gemfiles)/}) ||
      f.start_with?('.') ||
      %w[Appraisals Gemfile Rakefile].include?(f)
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rake", "~> 10.0"
end

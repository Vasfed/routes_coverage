# frozen_string_literal: true

# to test against all, run: appraisal rake spec

if RUBY_VERSION <= '2.4'
  # to get a working ruby 2.3: `docker run --rm -it --volume $PWD:/app ruby:2.3-stretch bash`
  # to get a working ruby 1.9: `docker run --rm -it --volume $PWD:/app ruby:1.9.3-wheezy bash`
  appraise 'rails-3' do
    gem 'rails', '~>3.2.22'
    gem 'test-unit'
    # helping old bundler with correct versions with support for ruby 1.9:
    if RUBY_VERSION < '2'
      gem 'rake', '~> 11.3'
      gem 'concurrent-ruby', '1.1.9'
      gem 'rack-cache', '1.7.0'
      gem 'thor', '0.20.3'
      gem 'appraisal', '2.2.0'
      gem 'minitest', '5.11.3'
    end
  end

  appraise 'rails-40' do
    gem 'rails', '~>4.0.0'
  end

  appraise 'rails-42' do
    gem 'rails', '~>4.2.0'
  end
else
  appraise 'rails-5' do
    gem 'rails', '~>5.0.0'
  end

  appraise 'rails-50+rspec' do
    gem 'rails', '~>5.0.0'
    gem 'rspec-rails'
  end

  appraise 'rails-50+simplecov' do
    gem 'rails', '~>5.0.0'
    gem 'simplecov'
  end

  appraise 'rails-51' do
    gem 'rails', '~>5.1.0'
  end

  appraise 'rails-6' do
    gem 'rails', '~>6.0.4'
  end

  appraise 'rails-7' do
    gem 'rails', '~>7.0.2'
  end
end

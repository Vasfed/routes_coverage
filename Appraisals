# frozen_string_literal: true

# to test against all, run: appraisal rake spec

if RUBY_VERSION <= '2.4'
  # to get a working ruby 2.3: `docker run --rm -it --volume $PWD:/app ruby:2.3-stretch bash`
  appraise 'rails-3' do
    gem 'rails', '~>3.2.22'
    gem 'test-unit'
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
end

# RoutesCoverage
[![Gem Version](https://badge.fury.io/rb/routes_coverage.svg)](https://badge.fury.io/rb/routes_coverage)


Sometimes you need to know which routes are covered by your rails test suite.

(more detailed readme coming soon)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'routes_coverage', group: :test
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install routes_coverage

## Usage

Install the gem and run your tests. By default you'll see something like:

    # Running tests:

    ....

    Finished tests in 0.037646s, 106.2530 tests/s, 106.2530 assertions/s.

    4 tests, 4 assertions, 0 failures, 0 errors, 0 skips
    Routes coverage is 11.1% (1 of 9 routes hit at 1.0 hits average)

To get more detailed information somewhere in your test helper add

```ruby
RoutesCoverage.settings.format = :full_text
```

or into RSpec config:

```ruby
RSpec.configure do |config|
  config.routes_coverage.format = :full_text
end
```

    Routes coverage is 11.1% (1 of 9 routes hit at 1.0 hits average)
    Coverage failed. Need at least 8

    Covered routes:
     Verb URI Pattern             Controller#Action Hits
     POST /reqs/current(.:format) dummy#current     1

    Pending routes:
      Verb   URI Pattern              Controller#Action
      GET    /reqs(.:format)          dummy#index
      POST   /reqs(.:format)          dummy#create
      GET    /reqs/new(.:format)      dummy#new
      GET    /reqs/:id/edit(.:format) dummy#edit
      GET    /reqs/:id(.:format)      dummy#show
      PATCH  /reqs/:id(.:format)      dummy#update
      PUT    /reqs/:id(.:format)      dummy#update
      DELETE /reqs/:id(.:format)      dummy#destroy


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

To run tests against different rails versions use `appraisal rake`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Vasfed/routes_coverage.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

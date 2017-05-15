# RoutesCoverage
[![Gem Version](https://badge.fury.io/rb/routes_coverage.svg)](https://badge.fury.io/rb/routes_coverage)


Sometimes you need to know which routes are covered by your rails test suite.

![Html output example](/assets/html_output_screenshot.png?raw=true "Html Output example")


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

Install the gem and run your tests, then open generated report file `coverage/routes.html`.


### Configuration

By default html report with no groupping is generated. If you need more funtionality - options in `RoutesCoverage.settings` or rspec's `config.routes_coverage`:

```ruby
RSpec.configure do |config|
  config.routes_coverage.perform_report = ENV['ROUTES_COVERAGE'] # only generate report if env var is set

  config.routes_coverage.exclude_patterns << %r{PATCH /reqs}   # excludes all requests matching regex
  config.routes_coverage.exclude_namespaces << 'somenamespace' # excludes /somenamespace/*

  config.routes_coverage.groups["Some Route group title"] = %r{^/somespace/}
  config.routes_coverage.groups["Admin"] = Regexp.union([
    %r{^/admin/},
    %r{^/secret_place/},
  ])

  config.routes_coverage.format = :html # html is default, others are :full_text and :summary_text, or your custom formatter class

  config.routes_coverage.minimum_coverage = 80 # %, your coverage goal
  config.routes_coverage.round_precision = 0   # just round to whole percents
end
```
Excluded routes do not show in pending, but are shown if they're hit.

If rspec is not your choice - use

```ruby
RoutesCoverage.configure do |config|
  config.format = :full_text
  # ...
end
```

or

```ruby
RoutesCoverage.settings.format = :full_text
```



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

To run tests against different rails versions use `appraisal rake`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Vasfed/routes_coverage.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

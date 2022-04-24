# Changelog

## Unreleased

-

## 0.7.0 - April 24, 2022
- Support for Rails 7 (added tests, main code was already working)
- Fixed: errors on Rails 3 and ruby 2.3
- New feature: `require 'routes_coverage/auditor'; RoutesCoverage::Auditor.new.print_missing_actions` detects actions present in routes, but not present in controllers.
  `print_unused_actions` - the other direction. Useful for routes cleanup.

- Known bug: collecting coverage data from engines is still not supported :(

## 0.6.0 - November 15, 2021
- New: ability to infer coverage from controller tests: `config.routes_coverage.include_from_controller_tests = true`
  This is not very accurate, but might help in old apps with lots of controller tests.

## 0.5.2 - November 15, 2021
- Default tests are on rails 5
- Few minor bugfixes
- Code cleanup
- Trying to support ruby < 2.3

## 0.4.3 - April 09, 2018
- Support for rails 3.2 (may work on 3.0, but not tested)
- Support for rails 5.2.rc
- Better rspec and simplecov compatibility
- Fix route params in constraints

## 0.3.3 - June 24, 2017
- Option to ignore PUT-fallback routes: `config.routes_coverage.exclude_put_fallbacks = true`
- Fix routes with constraints
- Fix redirect routes
- Fix 404 from mounted engines

## 0.2.2 - May 15, 2017
- Config flag to skip reporting: `config.routes_coverage.perform_report = false`
- Fix catch-all route

## 0.1.1 - May 15, 2017
- Html report generation

## 0.0.3 - May 14, 2017
- Support for groups

## 0.0.2 - May 12, 2017
- Test on rails 5.1

## 0.0.1 - May 11, 2017
- First release, supports rails 4

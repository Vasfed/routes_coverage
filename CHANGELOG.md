# Changelog

## Unreleased

-

## 0.7.0

- Support for Rails 7 (added tests, main code was already working)
- Fixed: errors on Rails 3 and ruby 2.3
- New feature: `require 'routes_coverage/auditor'; RoutesCoverage::Auditor.new.print_missing_actions` detects actions present in routes, but not present in controllers.
  `print_unused_actions` - the other direction. Useful for routes cleanup.

- Known bug: collecting coverage data from engines is still not supported :(

## <= 0.6.0

In commit history, sorry
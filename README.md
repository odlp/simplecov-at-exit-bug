# SimpleCov 0.18.3 at_exit bug

## Issue

In a Rails application tested with RSpec (using the `rspec-rails` gem) the
coverage report is not generated after the test suite has run.

## Minimal reproduction

- Clone this repo & run `bundle install`
- Run `bundle exec rspec`
- Comment/uncomment the `require "active_support/test_case"` in `spec/foo_spec.rb` to observe the issue

## Tracing the issue

When `ActiveSupport::TestCase` is required, by RSpec Rails for example:

https://github.com/rspec/rspec-rails/blob/e23efbb2cd6b40aaa8c6f33a36fe7ed4e724e2c7/spec/rspec/rails/matchers/redirect_to_spec.rb#L2

This ends up requiring `minitest`:

https://github.com/rails/rails/blob/c70112e74f4d2ef517f4036fe6e2888cc30fc952/activesupport/lib/active_support/test_case.rb#L4

Unfortunately Minitest is a dependency of ActiveSupport:

https://github.com/rails/rails/blob/c70112e74f4d2ef517f4036fe6e2888cc30fc952/activesupport/activesupport.gemspec#L38

By having defined `Minitest`, this means the SimpleCov `at_exit` hook will skip
the 'at exit behaviour' hook:

```ruby
at_exit do
  # Exit hook for Minitest defined in Minitest plugin
  next if defined?(Minitest)

  SimpleCov.at_exit_behavior
end
```

https://github.com/colszowka/simplecov/blob/a179ec6dc419c43bce472c2426f30f24cc49b42f/lib/simplecov/defaults.rb#L24-L29

PRs which introduced this behaviour:

  - https://github.com/colszowka/simplecov/pull/855
  - https://github.com/colszowka/simplecov/pull/756

## Workaround

```ruby
RSpec.configure do |config|
  config.after(:suite) { SimpleCov.at_exit_behavior }
end
```

# frozen_string_literal: true

require 'bundler'
require 'English'
Bundler.require(:default)

require 'minitest/autorun'

describe "Minitest coverage" do
  def run_cmd(cmd)
    output = `#{cmd}`

    # HACK: minitest into displaying more readable error:
    def output.inspect
      "\n#{to_s.gsub(/^/, "\t> ")}"
    end
    [output, $CHILD_STATUS]
  end

  def run_dummy_test(testfile = 'dummy_test.rb')
    run_cmd("bundle exec ruby #{__dir__}/fixtures/#{testfile}")
  end

  def run_dummy_rspec(testfile = 'dummy_rspec.rb')
    run_cmd("bundle exec rspec #{__dir__}/fixtures/#{testfile}")
  end

  it "works" do
    res, code = run_dummy_test 'dummy_test.rb'
    _(code.success?).must_equal true
    _(res).must_match(/\d+ assertions, 0 failures, 0 errors, 0 skips/)
    _(res).must_match(/Routes coverage is (\d+(.\d+)?)%/)
  end

  it "has route listing" do
    res, code = run_dummy_test('dummy_test_full.rb')
    _(code.success?).must_equal true
    _(res).must_match %r{POST\s+/reqs/current\(\.:format\)\s+dummy#current\s+1}
    _(res).must_match(/dummy#update/)
  end

  it "does not count catch-all routes" do
    res, code = run_dummy_test 'dummy_test_full.rb'
    _(code.success?).must_equal true
    _(res).must_match(/dummy#not_found_error/)
    _(res).wont_match(/dummy#not_found_error\s+\d/)
  end

  it "has namespace filters" do
    res, code = run_dummy_test 'dummy_test_nsfilters.rb'
    _(code.success?).must_equal true
    _(res).must_match %r{POST\s+/reqs/current\(\.:format\)\s+dummy#current\s+1}
    _(res).wont_match %r{/somespace/}
    _(res).must_match %r{/otherspace/}
  end

  it "has regex filters" do
    res, code = run_dummy_test 'dummy_test_refilters.rb'
    _(code.success?).must_equal true
    _(res).must_match %r{POST\s+/reqs/current\(\.:format\)\s+dummy#current\s+1}
    _(res).wont_match %r{/PATCH/}
    _(res).wont_match %r{/index/}
  end

  it "generates html report" do
    res, code = run_dummy_test 'dummy_html.rb'
    _(code.success?).must_equal true
    _(res).must_include "coverage/routes.html"
    _(File.file?('coverage/routes.html')).must_equal true
  end

  it "filters fallback put-routes" do
    skip if Rails.version < '4'
    res, code = run_dummy_test 'put_test.rb'
    _(code.success?).must_equal true
    _(res).must_match %r{PUT\s+/standalone_put}
    _(res).must_match %r{PUT\s+/used_put/:}
    _(res).wont_match %r{PUT\s+/reqs/:}
  end

  it "supports redirect routes" do
    res, code = run_dummy_test 'redirect_test.rb'
    _(code.success?).must_equal true
    _(res).must_match %r{GET\s+/}
    _(res).must_match(/Routes coverage is 50/)
    _(res).must_match(/1 of 2 routes hit/)
  end

  it "constraints_differ" do
    res, code = run_dummy_test 'constraints_test.rb'
    _(code.success?).must_equal true
    _(res).must_match %r{GET\s+/rec\(\.:format\)\s+dummy#index\s+1}
    _(res).must_match %r{GET\s+/rec\(\.:format\)\s+dummy#update\s+1}
    _(res).must_match %r{GET\s+/rec/:TYPE\(\.:format\)\s+dummy#current\s+1}
  end

  it "groups" do
    res, code = run_dummy_test 'dummy_test_groups.rb'
    _(code.success?).must_equal true
    _(res).must_include "Some group: 0.0% (0 of 1 routes hit)"
    _(res).must_include "Foo: 33.3% (1 of 3 routes hit at 1.0 hits average)"
    _(res).must_include "Subdomain: 0.0% (0 of 1 routes hit)"
    _(res).must_include "Ungroupped: 33.3% (1 of 3 routes hit at 1.0 hits average)"
  end

  it "working mounted engines, including Sprockets" do
    skip if Rails.version < '4'
    res, code = run_dummy_test 'sprockets_test.rb'
    _(code.success?).must_equal true
    _(res).must_match(/Routes coverage is (\d+(.\d+)?)%/)
  end

  it "inferring coverage by controller tests" do
    ENV['INFER_FROM_CONTROLLER'] = '1'
    res, code = run_dummy_test 'dummy_controller_test.rb'
    route_regex = %r{GET\s+/reqs\(\.:format\)\s+dummy#index\s+1}
    _(code.success?).must_equal true
    _(res).must_match(route_regex)

    ENV['INFER_FROM_CONTROLLER'] = '0'
    res, code = run_dummy_test 'dummy_controller_test.rb'
    _(code.success?).must_equal true
    _(res).wont_match(route_regex)
  end

  if defined? RSpec
    it "works with rspec" do
      res, code = run_dummy_rspec 'dummy_rspec.rb'
      _(code.success?).must_equal true
      _(res).must_match(/Routes coverage is (\d+(.\d+)?)%/)
    end
  end

  if defined? SimpleCov
    it "works with simplecov" do
      res, code = run_dummy_test 'dummy_test_simplecov.rb'
      _(code.success?).must_equal true
      _(res).must_match(/Routes coverage is (\d+(.\d+)?)%/)
      _(res).must_match(/routes\.html/)
      # File.file?(?../routes.html).must_equal true
    end
  end
end

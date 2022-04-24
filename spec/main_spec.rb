# frozen_string_literal: true

require 'bundler'
require 'English'
Bundler.require(:default)

require 'minitest/autorun'
require 'minitest/spec'

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
    assert(code.success?)
    assert_match(/\d+ assertions, 0 failures, 0 errors, 0 skips/, res)
    assert_match(/Routes coverage is (\d+(.\d+)?)%/, res)
  end

  it "has route listing" do
    res, code = run_dummy_test('dummy_test_full.rb')
    assert(code.success?)
    assert_match(%r{POST\s+/reqs/current\(\.:format\)\s+dummy#current\s+1}, res)
    assert_match(/dummy#update/, res)
  end

  it "does not count catch-all routes" do
    res, code = run_dummy_test 'dummy_test_full.rb'
    assert(code.success?)
    assert_match(/dummy#not_found_error/, res)
    refute_match(/dummy#not_found_error\s+\d/, res)
  end

  it "has namespace filters" do
    res, code = run_dummy_test 'dummy_test_nsfilters.rb'
    assert(code.success?)
    assert_match(%r{POST\s+/reqs/current\(\.:format\)\s+dummy#current\s+1}, res)
    refute_match(%r{/somespace/}, res)
    assert_match(%r{/otherspace/}, res)
  end

  it "has regex filters" do
    res, code = run_dummy_test 'dummy_test_refilters.rb'
    assert(code.success?)
    assert_match(%r{POST\s+/reqs/current\(\.:format\)\s+dummy#current\s+1}, res)
    refute_match(%r{/PATCH/}, res)
    refute_match(%r{/index/}, res)
  end

  it "generates html report" do
    res, code = run_dummy_test 'dummy_html.rb'
    assert(code.success?)
    assert_includes(res, "coverage/routes.html")
    assert(File.file?('coverage/routes.html'))
  end

  it "filters fallback put-routes" do
    skip if Rails.version < '4'
    res, code = run_dummy_test 'put_test.rb'
    assert(code.success?)
    assert_match(%r{PUT\s+/standalone_put}, res)
    assert_match(%r{PUT\s+/used_put/:}, res)
    refute_match(%r{PUT\s+/reqs/:}, res)
  end

  it "supports redirect routes" do
    res, code = run_dummy_test 'redirect_test.rb'
    assert(code.success?)
    assert_match(%r{GET\s+/}, res)
    assert_match(/Routes coverage is 50/, res)
    assert_match(/1 of 2 routes hit/, res)
  end

  it "constraints_differ" do
    res, code = run_dummy_test 'constraints_test.rb'
    assert(code.success?)
    assert_match(%r{GET\s+/rec\(\.:format\)\s+dummy#index\s+1}, res)
    assert_match(%r{GET\s+/rec\(\.:format\)\s+dummy#update\s+1}, res)
    assert_match(%r{GET\s+/rec/:TYPE\(\.:format\)\s+dummy#current\s+1}, res)
  end

  it "groups" do
    res, code = run_dummy_test 'dummy_test_groups.rb'
    assert(code.success?)
    assert_includes(res, "Some group: 0.0% (0 of 1 routes hit)")
    assert_includes(res, "Foo: 50.0% (1 of 2") # (4 total)? routes hit at 1.0 hits average)")
    assert_includes(res, "Subdomain: 0.0% (0 of 1 routes hit)")
    assert_includes(res, "Ungroupped: 33.3% (1 of 3 routes hit at 1.0 hits average)")
  end

  it "working mounted engines, including Sprockets" do
    skip if Rails.version < '4'
    res, code = run_dummy_test 'sprockets_test.rb'
    assert(code.success?)
    assert_match(/Routes coverage is (\d+(.\d+)?)%/, res)
  end

  it "inferring coverage by controller tests" do
    # TODO: find a way for older rails
    skip if Rails::VERSION::MAJOR <= 4
    ENV['INFER_FROM_CONTROLLER'] = '1'
    res, code = run_dummy_test 'dummy_controller_test.rb'
    route_regex = %r{GET\s+/reqs\(\.:format\)\s+dummy#index\s+1}
    assert(code.success?)
    assert_match(route_regex, res)

    ENV['INFER_FROM_CONTROLLER'] = '0'
    res, code = run_dummy_test 'dummy_controller_test.rb'
    assert(code.success?)
    refute_match(route_regex, res)
  end

  it "can detect missing actions from routes" do
    res, code = run_dummy_test 'dummy_test_missing_actions.rb'
    assert(code.success?)
    assert_includes(res, "Controller somespace/foo looks not existing")
    assert_includes(res, "Controller otherspace/bar looks not existing")
    assert_includes(res, "Controller subdomain_route looks not existing")
    assert_includes(res, "Missing 6 actions:")

    _, missing_actions = res.split("Missing 6 actions:\n", 2)
    assert_equal(<<~TXT, missing_actions)
      dummy: create, except: %i[new create show edit destroy], only: %i[index update] ,  Missing custom: some_custom, not_found_error
      somespace/foo: index, except: %i[index new create show edit update destroy], only: %i[]
      otherspace/bar: index, except: %i[index new create show edit update destroy], only: %i[]
      subdomain_route: index, except: %i[index new create show edit update destroy], only: %i[]
    TXT
  end

  if defined? RSpec
    it "works with rspec" do
      res, code = run_dummy_rspec 'dummy_rspec.rb'
      assert(code.success?)
      assert_match(/Routes coverage is (\d+(.\d+)?)%/, res)
    end
  end

  if defined? SimpleCov
    it "works with simplecov" do
      res, code = run_dummy_test 'dummy_test_simplecov.rb'
      assert(code.success?)
      assert_match(/Routes coverage is (\d+(.\d+)?)%/, res)
      assert_match(/routes\.html/, res)
      # assert(File.file?(?../routes.html))
    end
  end
end

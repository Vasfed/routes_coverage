require 'bundler'
Bundler.require(:default)

require 'minitest/autorun'

describe "Minitest coverage" do

  def run_cmd cmd
    output = `#{cmd}`

    #hack minitest into displaying more readable error:
    def output.inspect
      "\n#{to_s.gsub(/^/, "\t> ")}"
    end
    return [output, $?]
  end

  def run_dummy_test testfile='dummy_test.rb'
    run_cmd "bundle exec ruby #{File.dirname(__FILE__)}/fixtures/#{testfile}"
  end

  def run_dummy_rspec testfile='dummy_rspec.rb'
    run_cmd "bundle exec rspec #{File.dirname(__FILE__)}/fixtures/#{testfile}"
  end

  it "works" do
    res, code = run_dummy_test 'dummy_test.rb'
    code.success?.must_equal true
    res.must_match /\d+ assertions, 0 failures, 0 errors, 0 skips/
    res.must_match /Routes coverage is (\d+(.\d+)?)%/
  end

  it "has route listing" do
    res, code = run_dummy_test 'dummy_test_full.rb'
    code.success?.must_equal true
    res.must_match %r{POST\s+/reqs/current\(\.:format\)\s+dummy#current\s+1}
    res.must_match /dummy#update/
  end

  it "does not count catch-all routes" do
    res, code = run_dummy_test 'dummy_test_full.rb'
    code.success?.must_equal true
    res.must_match %r{dummy#not_found_error}
    res.wont_match %r{dummy#not_found_error\s+\d}
  end

  it "has namespace filters" do
    res, code = run_dummy_test 'dummy_test_nsfilters.rb'
    code.success?.must_equal true
    res.must_match %r{POST\s+/reqs/current\(\.:format\)\s+dummy#current\s+1}
    res.wont_match %r{/somespace/}
    res.must_match %r{/otherspace/}
  end

  it "has regex filters" do
    res, code = run_dummy_test 'dummy_test_refilters.rb'
    code.success?.must_equal true
    res.must_match %r{POST\s+/reqs/current\(\.:format\)\s+dummy#current\s+1}
    res.wont_match %r{/PATCH/}
    res.wont_match %r{/index/}
  end

  it "generates html report" do
    res, code = run_dummy_test 'dummy_html.rb'
    code.success?.must_equal true
    File.file?('coverage/routes.html').must_equal true
  end

  it "filters fallback put-routes" do
    res, code = run_dummy_test 'put_test.rb'
    code.success?.must_equal true
    res.must_match %r|PUT\s+/standalone_put|
    res.must_match %r|PUT\s+/used_put/:|
    res.wont_match %r|PUT\s+/reqs/:|
  end

  it "constraints_differ" do
    res, code = run_dummy_test 'constraints_test.rb'
    code.success?.must_equal true
    res.must_match %r|GET\s+/rec\(\.:format\)\s+dummy#index\s+1|
    res.must_match %r|GET\s+/rec\(\.:format\)\s+dummy#update\s+1|
  end

  it "working mounted engines, including Sprockets" do
    res, code = run_dummy_test 'sprockets_test.rb'
    code.success?.must_equal true
  end

  if defined? RSpec
    it "works with rspec" do
      res,code = run_dummy_rspec 'dummy_rspec.rb'
      code.success?.must_equal true
      res.must_match /Routes coverage is (\d+(.\d+)?)%/
    end
  end

  if defined? SimpleCov
    it "works with simplecov" do
      res,code = run_dummy_test 'dummy_test_simplecov.rb'
      code.success?.must_equal true
      res.must_match /Routes coverage is (\d+(.\d+)?)%/
      res.must_match /routes\.html/
      # File.file?(?../routes.html).must_equal true
    end
  end

end

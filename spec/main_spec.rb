require 'bundler'
Bundler.require(:default)

require 'minitest/autorun'

describe "Minitest coverage" do

  def run_dummy_test params=nil
    output = `bundle exec ruby #{File.dirname(__FILE__)}/fixtures/dummy_test.rb #{params}`
    return [output, $?]
  end

  it "works" do
    res, code = run_dummy_test

    # puts "#{'-'*20}\n#{res}#{'-'*20}\n"
    code.success?.must_equal true
    res.must_match /\d+ assertions, 0 failures, 0 errors, 0 skips/
    res.must_match /Routes coverage is (\d+(.\d+)?)%/
  end

  it "has route listing" do
    res, code = run_dummy_test 'full_text'
    code.success?.must_equal true
    res.must_match %r{POST\s+/reqs/current\(\.:format\)\s+dummy#current\s+1}
    res.must_match /dummy#update/
  end

  if defined? RSpec
    it "works with rspec" do
      res = `bundle exec rspec #{File.dirname(__FILE__)}/fixtures/dummy_rspec_test.rb`
      code = $?
      code.success?.must_equal true
      res.must_match /Routes coverage is (\d+(.\d+)?)%/
    end
  end

end

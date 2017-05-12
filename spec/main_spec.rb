require 'bundler'
Bundler.require(:default)

require 'minitest/autorun'

describe "Minitest coverage" do

  it "works" do
    res = `bundle exec ruby #{File.dirname(__FILE__)}/fixtures/dummy_test.rb`

    # puts "#{'-'*20}\n#{res}#{'-'*20}\n"

    res.must_match /\d+ assertions, 0 failures, 0 errors, 0 skips/
    res.must_match /Routes coverage is (\d+(.\d+)?)%/
  end

  if defined? RSpec
    it "works with rspec" do
      res = `bundle exec rspec #{File.dirname(__FILE__)}/fixtures/dummy_rspec_test.rb`
      #TODO: check exit code
      res.must_match /Routes coverage is (\d+(.\d+)?)%/
    end
  end

end

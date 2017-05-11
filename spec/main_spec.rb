require 'minitest/autorun'

describe "Minitest coverage" do

  it "works" do
    res = `bundle exec ruby #{File.dirname(__FILE__)}/fixtures/dummy_app.rb`

    puts "#{'-'*20}\n#{res}#{'-'*20}\n"

    res.must_match /\d+ tests, \d+ assertions, 0 failures, 0 errors, 0 skips/
    res.must_match /Routes coverage is (\d+(.\d+)?)%/
  end

end

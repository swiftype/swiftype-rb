require 'bundler/setup'
require 'rspec'
require 'vcr'
require 'awesome_print'
require 'swiftype'

RSpec.configure do |config|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  VCR.configure do |c|
    c.cassette_library_dir = 'spec/fixtures/vcr'
    c.hook_into :webmock
    #c.default_cassette_options = {:record => :all}
  end

  config.before :each do
    Swiftype.endpoint = "http://localhost:3000/api/v1/"
  end

  config.after :each do
    Swiftype.reset
  end
end

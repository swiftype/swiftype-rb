require 'bundler/setup'
require 'rspec'
require 'swiftype'

RSpec.configure do |config|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.backtrace_clean_patterns = [
    /\/lib\d*\/ruby\//,
    /bin\//,
    /spec\/spec_helper\.rb/,
    /lib\/rspec\/(core|expectations|matchers|mocks)/
  ]
end

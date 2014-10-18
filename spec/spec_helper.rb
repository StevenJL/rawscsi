$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

ENV["RAILS_ENV"] ||= "test"

require "vcr"
require "rawscsi"


VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr"  
  config.hook_into :fakeweb
  config.default_cassette_options = {:record => :once}
  config.ignore_hosts "codeclimate.com"
end


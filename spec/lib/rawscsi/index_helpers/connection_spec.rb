$root = File.expand_path('../../../../../', __FILE__)
require "#{$root}/spec/spec_helper"

describe Rawscsi::IndexHelpers::Connection do
  before(:each) do
    @config = Rawscsi::Configuration.new
    @config.domain_name = "good-songs"
    @config.domain_id = "bxfbnuitrk2tayljprycpx6mna"
    @config.region = "us-west-1"
    @config.api_version = "2013-01-01"
  end

  it "constructs the url correctly" do
    connection = Rawscsi::IndexHelpers::Connection.new(@config)
    expect(connection.url).to eq("http://doc-good-songs-bxfbnuitrk2tayljprycpx6mna.us-west-1.cloudsearch.amazonaws.com")
  end

  it "builds a faraday object" do
    VCR.use_cassette("faraday_object") do
      faraday = Rawscsi::IndexHelpers::Connection.new(@config).build
      expect(faraday).to be_kind_of(Faraday::Connection)
    end
  end
end


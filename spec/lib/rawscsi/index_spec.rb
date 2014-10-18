require "json"
$root = File.expand_path('../../../../', __FILE__)
puts "#{$root}"
require "#{$root}/spec/spec_helper"

describe Rawscsi::Index do
  before(:each) do
    Rawscsi.register "Dummy" do |config|
      # this domain has been deleted
      # so don't try anything funny ;)
      config.domain_name = "dummy-for-test"
      config.domain_id = "asshywvkb3xdxlpqj7uk3bf2lq"
      config.region = "us-east-1"
      config.api_version = "2013-01-01"
    end
    @indexer = Rawscsi::Index.new("Dummy")
  end

  it "instantiates properly" do
    expect(@indexer.config.domain_name).to eq("dummy-for-test")
    expect(@indexer.config.domain_id).to eq("asshywvkb3xdxlpqj7uk3bf2lq")
    expect(@indexer.config.region).to eq("us-east-1")
    expect(@indexer.config.api_version).to eq("2013-01-01")
  end

  it "uploads indices from hash correctly" do
    VCR.use_cassette("index_spec/upload_hash") do
      hash  = { :id => 12345678, :title => "Test Title", :desc => "Test Desc" }
      expect(JSON.parse(@indexer.upload([hash]))).to eq({
        "status" => "success",
        "adds" => 1,
        "deletes" => 0
      })
    end
  end

  it "partitions array of docs into right size" do
    VCR.use_cassette("index_spec/handle_batch_limit") do
      array_of_hashes = []
      10000.times do |index|
        rand_title = "title" * 16
        rand_desc = "desc" * 200
        array_of_hashes << { :id => index, :title => rand_title, :desc => rand_desc}
      end
      expect(JSON.parse(@indexer.upload(array_of_hashes))).to eq({
        "status" => "success",
        "adds" => 4399,
        "deletes" => 0
      })
    end
  end
  
  it "deletes indices correctly" do
    VCR.use_cassette("index_spec/delete") do
      expect(JSON.parse(@indexer.delete((1..10000).to_a))).to eq({
        "status" => "success",
        "adds" => 0,
        "deletes" => 10000})
    end
  end
end


$root = File.expand_path('../../../../../', __FILE__)
require "#{$root}/spec/spec_helper"

describe Rawscsi::Query::Simple do
  it "constructs a simple query" do
    str = "star wars"
    query = Rawscsi::Query::Simple.new(str).build
    expect(query).to eq("q=star+wars")
  end
end


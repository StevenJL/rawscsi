$root = File.expand_path('../../../../', __FILE__)
require "#{$root}/spec/spec_helper"

describe Rawscsi::RequestSignature do
  it "initializes config attrs correctly" do
    options = {
      secret_key: "test_secret_key",
      access_key_id: "test_access_key_id",
      region_name: "test_region_name",
      endpoint: "test_endpoint",
      method: "test_method",
      host: "test_host"
    }
    
    rs = Rawscsi::RequestSignature.new(options)
    expect(rs.send(:secret_key)).to eq("test_secret_key")
    expect(rs.send(:access_key_id)).to eq("test_access_key_id")
    expect(rs.send(:region_name)).to eq("test_region_name")
    expect(rs.send(:endpoint)).to eq("test_endpoint")
    expect(rs.send(:method)).to eq("test_method")
    expect(rs.send(:host)).to eq("test_host")
  end

  it "#date and amz_datetime work" do
    options = {
      secret_key: "test_secret_key",
      access_key_id: "test_access_key_id",
      region_name: "test_region_name",
      endpoint: "test_endpoint",
      method: "test_method",
      host: "test_host"
    }
    
    rs = Rawscsi::RequestSignature.new(options)
    date = rs.send(:date)
    amz_date = rs.send(:amz_datetime)

    expect(/\d{8}/).to match(date)
    expect(/\d{8}T\d{6}/).to match(amz_date)
  end
end


$root = File.expand_path('../../../../../', __FILE__)
require "#{$root}/spec/spec_helper"

describe Rawscsi::IndexHelpers::SdfDelete do
  it "constructs an sdf delete json for an id" do
    id = 4
    sdf_hash = Rawscsi::IndexHelpers::SdfDelete.new(id).build
    expect(sdf_hash).to eq({:type => "delete", :id => 4})
  end

  it "constructs an sdf delete json for an active record object" do
    obj = Movie.new(293428934, "Slingblade", ["Billy Bob Thorton", "Dwight Yokam"], 9)
    sdf_hash = Rawscsi::IndexHelpers::SdfDelete.new(obj).build
    expect(sdf_hash).to eq({:type => "delete", :id => "Movie_293428934"})
  end
end


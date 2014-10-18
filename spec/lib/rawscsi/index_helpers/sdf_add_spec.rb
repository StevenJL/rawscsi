$root = File.expand_path('../../../../../', __FILE__)
require "#{$root}/spec/spec_helper"

describe Rawscsi::IndexHelpers::SdfAdd do
  Movie = Struct.new(:id, :title, :actors, :rating)
  before(:each) do
    @config = [:title, :actors, :rating]
  end

  it "constructs an sdf add json for active record object" do
    obj = Movie.new(293428934, "Slingblade", ["Billy Bob Thorton", "Dwight Yokam"], 9)
    sdf_hash = Rawscsi::IndexHelpers::SdfAdd.new(obj, @config).build
    expect(sdf_hash).to eq(
      {
        :id=>"Movie_293428934",
        :type=>"add",
        :fields=>
          {:title=>"Slingblade",
           :actors=>["Billy Bob Thorton", "Dwight Yokam"],
           :rating=>9}
      }
    )
  end

  it "constructs an sdf add json for a hash" do
    obj = {
      :id => 43134353,
      :title => "Adaptation",
      :actors => ["Nicholas Cage", "Meryl Streep"],
      :rating => 9.5
    }
    sdf_hash = Rawscsi::IndexHelpers::SdfAdd.new(obj).build
    expect(sdf_hash).to eq(
      {:id=>43134353,
       :type=>"add",
       :fields=>
          {:title=>"Adaptation",
           :actors=>["Nicholas Cage", "Meryl Streep"],
           :rating=>9.5}
      }
    )
  end
end


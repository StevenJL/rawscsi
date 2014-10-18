$root = File.expand_path('../../../../../', __FILE__)
require "#{$root}/spec/spec_helper"

describe Rawscsi::Query::Compound do
  it "constructs a query that looks only at a single field" do
    arg = {:q => {:and => [{:title => "star wars"}]}}
    str = Rawscsi::Query::Compound.new(arg).build
    expect(str).to eq("q=(and%20title:%27star%20wars%27)&q.parser=structured")
  end

  it "constructs a query that looks only at a single field and specifies fields" do
    arg = {:q => {:and => [{:title => "star wars"}]}, :fields => [:title, :genres]}    
    str = Rawscsi::Query::Compound.new(arg).build
    expect(str).to eq("q=(and%20title:%27star%20wars%27)&return=title,genres&q.parser=structured")
  end

  it "constructs a query with a numeric range" do
    arg = { :q => { :and => [{:actors => "Arnold"}, {:title => "Terminator"},{:range => "rating:['8',}"}]},
            :fields => [:title]
          }
    str = Rawscsi::Query::Compound.new(arg).build
    expect(str).to eq("q=(and%20actors:%27Arnold%27title:%27Terminator%27rating:%5B%278%27,%7D)&return=title&q.parser=structured")
  end

  it "constructs a query with sort and limit options" do
    arg = { :q => {:and => [{:genres => "Sci-Fi"}]},
            :sort => "rating desc",
            :limit => 3,
            :fields => [:title]
          }
    str = Rawscsi::Query::Compound.new(arg).build
    expect(str).to eq("q=(and%20genres:%27Sci-Fi%27)&sort=rating%20desc&size=3&return=title&q.parser=structured")
  end

  it "constructs a query with date constraint" do
    arg = { :q => {:and => [{:plot => "James Bond"}]}, :date => { :release_date => "['1970-01-01',}"}}
    str = Rawscsi::Query::Compound.new(arg).build
    expect(str).to eq("q=(and%20plot:%27James%20Bond%27)&fq=release_date:%5B%271970-01-01T00:00:00Z%27,%7D&q.parser=structured")
  end

  it "constructs a query with a bounded date constraint" do
    arg = { :q => {:and => [{:plot => "James Bond"}]}, :date => { :release_date => "['1970-01-01','1980-01-01']"}}
    str = Rawscsi::Query::Compound.new(arg).build
    expect(str).to eq("q=(and%20plot:%27James%20Bond%27)&fq=release_date:%5B%271970-01-01T00:00:00Z%27,%271980-01-01T00:00:00Z%27%5D&q.parser=structured")
  end

  it "constructs a disjunction query" do
    arg = { :q => {:or => [{:actors => "Dustin Hoffman"},
                     {:actors => "Gary Oldman"},
                     {:actors => "Daniel Day Lewis"},
                     {:actors => "Christopher Walken"}]},
            :sort => "rating desc",
            :fields => [:title],
            :limit => 10}

    str = Rawscsi::Query::Compound.new(arg).build
    expect(str).to eq("q=(or%20actors:%27Dustin%20Hoffman%27actors:%27Gary%20Oldman%27actors:%27Daniel%20Day%20Lewis%27actors:%27Christopher%20Walken%27)&sort=rating%20desc&size=10&return=title&q.parser=structured")
  end

  it "contructs a combination of conjunction and disjunction query" do
    arg = {:q => {:and => [{:genres => "Action"},
                     {:or => [{:actors => "Stallon"},
                           {:actors => "Jackie"},
                           {:actors => "Arnold"},
                           {:actors => "Weathers"},
                           {:actors => "Van Damme"}]}]}}
    str = Rawscsi::Query::Compound.new(arg).build

    expect(str).to eq("q=(and%20genres:%27Action%27(or%20actors:%27Stallon%27actors:%27Jackie%27actors:%27Arnold%27actors:%27Weathers%27actors:%27Van%20Damme%27))&q.parser=structured")
  end

  it "contructs a query with negation" do
    arg = {:q => {:and => [{:title => "star"},
                           {:not => {:title => "wars"}}]}}
    str = Rawscsi::Query::Compound.new(arg).build

    expect(str).to eq("q=(and%20title:%27star%27(not%20title:%27wars%27))&q.parser=structured")
  end
end


$root = File.expand_path('../../../../', __FILE__)
require "#{$root}/spec/spec_helper"

describe Rawscsi::Search do
  before(:each) do
    Rawscsi.register 'Movies' do |config|
      # this was a live search domain when these tests were being written
      # but has been deleted, so don't try anything funny ;)
      config.domain_name = 'imdb-test'
      config.domain_id = 'klzdilptuleeedvxt7to3c5xl4'
      config.region = 'us-east-1'
      config.api_version = '2013-01-01'
    end

    @search_helper = Rawscsi::Search.new('Movies')
  end

  it 'instantiates properly' do
    expect(@search_helper.config.domain_name).to  eq('imdb-test')
    expect(@search_helper.config.domain_id).to  eq('klzdilptuleeedvxt7to3c5xl4')
    expect(@search_helper.config.region).to  eq('us-east-1')
    expect(@search_helper.config.api_version).to  eq('2013-01-01')
    expect(@search_helper.is_active_record).to be nil
  end
  
  it "has active_record option" do
    ar_search_helper = Rawscsi::Search.new("imdb-test", :active_record => true)  
    expect(ar_search_helper.is_active_record).to be true
  end

  it "performs a simple search with all fields returned" do
    VCR.use_cassette('search_spec/simple_search') do
      results = @search_helper.search('star wars')
      result_titles = results.map {|r| r["title"]}

      expect(result_titles).to include("Star Wars")
      expect(result_titles).to include("Star Wars: Episode I - The Phantom Menace")
    end
  end
  
  it "performs a search with specified return fields" do
    VCR.use_cassette("search_spec/fields") do
      results = @search_helper.search(:q => {:and => [{:title => "Die Hard"}]}, :fields => [:title, :genres])
      expect(results).to include({"genres"=>["Action", "Thriller"], "title" => "Die Hard"})
      expect(results).to include({"genres"=>["Action", "Thriller"], "title" => "Die Hard 2"})
    end
  end

  it "performs conjunction search over the same field" do
  # Find all movies starring both Kevin Bacon and Tom Hanks
    VCR.use_cassette("search_spec/and_same_field") do 
      results = @search_helper.search(:q => {:and => [{:actors => "Kevin Bacon"}, {:actors => "Tom Hanks"}]},
                                      :fields => [:title])

      expect(results).to eq([{"title" => "Apollo 13"}])
    end
  end

  it "performs conjunction search over two different fields" do
    VCR.use_cassette("search_spec/and_diff_field") do
      results = @search_helper.search(:q => {:and => [{:actors => "Arnold"},
                                                {:title => "Terminator"}]},
                                      :fields => [:title])
      expect(results).to eq([{"title"=>"Terminator"},
                             {"title"=>"The Terminator"},
                             {"title"=>"Terminator 2: Judgment Day"},
                             {"title"=>"Terminator 3: Rise of the Machines"}])
    end
  end

  it "performs conjunction search with numeric range" do
    # Find the Terminator movies rated higher than 8 
    VCR.use_cassette("search_spec/numeric_range") do
      results = @search_helper.search(:q => { :and => [{:actors => "Arnold"},
                                                 {:title => "Terminator"},
                                                 {:range => "rating:['8',}"}]
                                         },
                                      :fields => [:title])
      expect(results).to eq([{"title"=>"The Terminator"},
                             {"title"=>"Terminator 2: Judgment Day"}])
    end
  end

  it "works with limit and sort options" do
    # Find the top three Sci-Fi films
    VCR.use_cassette("search_spec/limit_sort") do
      results = @search_helper.search(:q => {:and => [{:genres => "Sci-Fi"}]},
                                      :sort => "rating desc",
                                      :limit => 3,
                                      :fields => [:title])
      expect(results).to eq([
              {"title"=> "Star Wars: Episode V - The Empire Strikes Back"},
              {"title"=>"Inception"},
              {"title"=>"The Matrix"}])
    end
  end

  it "works with date constraints" do
    # Find all James Bond films released after 1970
    VCR.use_cassette("search_spec/date") do
      results = @search_helper.search(:q => {:and => [{:plot => "James Bond"}]},
                                      :date => { :release_date => "['1970-01-01',}" },
                                      :fields => [:title])
      expect(results).to eq([{"title"=>"Moonraker"},
                             {"title"=>"Never Say Never Again"},
                             {"title"=>"The Living Daylights"},
                             {"title"=>"Tomorrow Never Dies"},
                             {"title"=>"The World Is Not Enough"},
                             {"title"=>"GoldenEye"},
                             {"title"=>"Diamonds Are Forever"},
                             {"title"=>"The Spy Who Loved Me"},
                             {"title"=>"Die Another Day"},
                             {"title"=>"Octopussy"}])
    end
  end

  it "performs disjunction searches" do
    # Finds the top ten movies staring any one of these amazing actors
    VCR.use_cassette("search_spec/disjunction") do
      results = @search_helper.search( 
                  :q => {:or => [{:actors => "Dustin Hoffman"},
                           {:actors => "Gary Oldman"},
                           {:actors => "Daniel Day Lewis"},
                           {:actors => "Christopher Walken"}]},
                  :sort => "rating desc",
                  :fields => [:title],
                  :limit => 10)
      expect(results).to include({"title"=>"The Deer Hunter"})
      expect(results).to include({"title"=>"In the Name of the Father"})
      expect(results).to include({"title"=>"The Graduate"})
      expect(results).to include({"title"=>"There Will Be Blood"})
      expect(results).to include({"title"=>"Papillon"})
      expect(results).to include({"title"=>"All the President's Men"})
    end
  end

  it "performs a combination of conjunction and disjunction search" do
    # Find the top action movies by these action stars
    VCR.use_cassette("search_spec/and_or_combo") do
      results = @search_helper.search( 
                  :q => {:and => [{:genres => "Action"},
                            {:or => [{:actors => "Stallon"},
                                  {:actors => "Jackie"},
                                  {:actors => "Arnold"},
                                  {:actors => "Weathers"},
                                  {:actors => "Van Damme"}]}]},
                  :sort => "rating desc",
                  :fields => [:title],
                  :limit => 10)
      expect(results).to eq([{"title"=>"Terminator 2: Judgment Day"},
                             {"title"=>"The Terminator"},
                             {"title"=>"Predator"},
                             {"title"=>"First Blood"},
                             {"title"=>"Watchmen"},
                             {"title"=>"Escape Plan"},
                             {"title"=>"Jui kuen II"},
                             {"title"=>"Total Recall"},
                             {"title"=>"Kung Fu Panda 2"},
                             {"title"=>"True Lies"}])
    end
  end
  
  it "can handle no results gracefully" do
    VCR.use_cassette("search_spec/no_result") do
      results = @search_helper.search("fasdfiojfd")   
      expect(results).to eq([])
    end
  end
end


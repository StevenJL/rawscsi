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
      expect(results).to include({"genres"=>["Action", "Thriller"], "title" => "Die Hard", "id" => "tt0095016"})
      expect(results).to include({"genres"=>["Action", "Thriller"], "title" => "Die Hard 2", "id"=>"tt0099423"})
    end
  end

  it "performs conjunction search over the same field" do
  # Find all movies starring both Kevin Bacon and Tom Hanks
    VCR.use_cassette("search_spec/and_same_field") do 
      results = @search_helper.search(:q => {:and => [{:actors => "Kevin Bacon"}, {:actors => "Tom Hanks"}]},
                                      :fields => [:title])

      expect(results).to eq([{"title" => "Apollo 13", "id"=>"tt0112384"}])
    end
  end

  it "performs conjunction search over two different fields" do
    VCR.use_cassette("search_spec/and_diff_field") do
      results = @search_helper.search(:q => {:and => [{:actors => "Arnold"},
                                                {:title => "Terminator"}]},
                                      :fields => [:title])
      expect(results).to eq([{"title"=>"Terminator", "id"=>"tt1340138"},
                             {"title"=>"The Terminator", "id"=>"tt0088247"},
                             {"title"=>"Terminator 2: Judgment Day", "id"=>"tt0103064"},
                             {"title"=>"Terminator 3: Rise of the Machines", "id"=>"tt0181852"}])
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
      expect(results).to eq([{"title"=>"The Terminator", "id"=>"tt0088247"},
                             {"title"=>"Terminator 2: Judgment Day", "id"=>"tt0103064"}])
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
        {"title"=>"Star Wars: Episode V - The Empire Strikes Back", "id"=>"tt0080684"},
        {"title"=>"Inception", "id"=>"tt1375666"},
        {"title"=>"The Matrix", "id"=>"tt0133093"}
      ])
    end
  end

  it "works with date constraints" do
    # Find all James Bond films released after 1970
    VCR.use_cassette("search_spec/date") do
      results = @search_helper.search(:q => {:and => [{:plot => "James Bond"}]},
                                      :date => { :release_date => "['1970-01-01',}" },
                                      :fields => [:title])
      expect(results).to eq([
        {"title"=>"Moonraker", "id"=>"tt0079574"},
        {"title"=>"Never Say Never Again", "id"=>"tt0086006"},
        {"title"=>"The Living Daylights", "id"=>"tt0093428"},
        {"title"=>"Tomorrow Never Dies", "id"=>"tt0120347"},
        {"title"=>"The World Is Not Enough", "id"=>"tt0143145"},
        {"title"=>"GoldenEye", "id"=>"tt0113189"},
        {"title"=>"Diamonds Are Forever", "id"=>"tt0066995"},
        {"title"=>"The Spy Who Loved Me", "id"=>"tt0076752"},
        {"title"=>"Die Another Day", "id"=>"tt0246460"},
        {"title"=>"Octopussy", "id"=>"tt0086034"}                            
      ])
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
      expect(results).to eq([
        {"title"=>"Léon", "id"=>"tt0110413"},
        {"title"=>"The Deer Hunter", "id"=>"tt0077416"},
        {"title"=>"In the Name of the Father", "id"=>"tt0107207"},
        {"title"=>"The Graduate", "id"=>"tt0061722"},
        {"title"=>"There Will Be Blood", "id"=>"tt0469494"},
        {"title"=>"Papillon", "id"=>"tt0070511"},
        {"title"=>"All the President's Men", "id"=>"tt0074119"},
        {"title"=>"Rain Man", "id"=>"tt0095953"},
        {"title"=>"JFK", "id"=>"tt0102138"},
        {"title"=>"Midnight Cowboy", "id"=>"tt0064665"}
      ])
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
      expect(results).to eq([
        {"title"=>"Terminator 2: Judgment Day", "id"=>"tt0103064"},
        {"title"=>"The Terminator", "id"=>"tt0088247"},
        {"title"=>"Predator", "id"=>"tt0093773"},
        {"title"=>"First Blood", "id"=>"tt0083944"},
        {"title"=>"Watchmen", "id"=>"tt0409459"},
        {"title"=>"Escape Plan", "id"=>"tt1211956"},
        {"title"=>"Jui kuen II", "id"=>"tt0111512"},
        {"title"=>"Total Recall", "id"=>"tt0100802"},
        {"title"=>"Kung Fu Panda 2", "id"=>"tt1302011"},
        {"title"=>"True Lies", "id"=>"tt0111503"}
      ])
    end
  end
  
  it "can handle no results gracefully" do
    VCR.use_cassette("search_spec/no_result") do
      results = @search_helper.search("fasdfiojfd")   
      expect(results).to eq([])
    end
  end
end


require "httparty"

module Rawscsi
  class Search < Base
    def search(arg)
      if arg.is_a?(String)  
        query = Rawscsi::Query::Simple.new(arg).build
      elsif arg.is_a?(Hash)
        query = Rawscsi::Query::Compound.new(arg).build
      else
        raise "Unknown argument type"
      end

      response = send_request_to_aws(query)
      build_results(response)
    end

    private
    def url(query)
      [
        "http://search-",
        "#{config.domain_name}-",
        "#{config.domain_id}.",
        "#{config.region}.",
        "cloudsearch.amazonaws.com/",
        "#{config.api_version}/",
        "search?",
        query
      ].join
    end

    def send_request_to_aws(query)
      url_query = url(query)
      HTTParty.get(url_query)
    end

    def build_results(response)
      if is_active_record
        Rawscsi::SearchHelpers::ResultsActiveRecord.new(response, model).build
      else
        Rawscsi::SearchHelpers::ResultsHash.new(response).build
      end
    end
  end
end


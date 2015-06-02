require "httparty"

module Rawscsi
  class Search < Base
    def search(arg, options = {})
      if arg.is_a?(String)  
        query = Rawscsi::Query::Simple.new(arg).build
        raw = options[:raw]
      elsif arg.is_a?(Hash)
        query = Rawscsi::Query::Compound.new(arg).build
        raw = arg[:raw]
      else
        raise "Unknown argument type"
      end

      response = send_request_to_aws(query)
      results = results_container(response)

      if raw
        results
      else
        build_results(results)
      end
    end

    private
    def url_schema
      config.use_https ? 'https' : 'http'
    end

    def canonical_url
      "/#{config.api_version}/search"
    end

    def search_domain
      config.search_domain || "search-#{config.domain_name}-#{config.domain_id}.#{config.region}.cloudsearch.amazonaws.com"
    end

    def url(query)
      [
        "#{url_schema}",
        "://",
        "#{search_domain}",
        "#{canonical_url}",
        '?',
        query
      ].join
    end

    def send_request_to_aws(query)
      url_query = url(query)
      
      signature = if config.access_key_id && config.secret_key
                  Rawscsi::RequestSignature.new({
                    secret_key: config.secret_key,
                    access_key_id: config.access_key_id,
                    region_name: config.region,
                    endpoint: canonical_url,
                    query: query,
                    method: 'GET',
                    host: search_domain,
                  }).build
                else
                  {}
                end
      HTTParty.get(url_query, headers: signature[:headers])
    end


    def results_container(response)
      if is_active_record
        Rawscsi::SearchHelpers::ResultsActiveRecord.new(response, model)
      else
        Rawscsi::SearchHelpers::ResultsHash.new(response)
      end
    end

    def build_results(results_container)
      results_container.build
    end
  end
end


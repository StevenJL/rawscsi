require "faraday"
require "faraday_middleware"

module Rawscsi
  module IndexHelpers
    class Connection
      attr_reader :url
      
      def initialize(config)
        @url = config.index_domain || "http://doc-#{config.domain_name}-#{config.domain_id}.#{config.region}.cloudsearch.amazonaws.com"
      end

      def build
        connection = Faraday.new url do |builder|
          builder.use FaradayMiddleware::EncodeJson
          builder.adapter Faraday.default_adapter
        end
        connection
      end
    end
  end
end


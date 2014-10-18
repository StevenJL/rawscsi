module Rawscsi
  module SearchHelpers
    class ResultsHash
      def initialize(response)    
        @response = response
      end

      def build
        @response["hits"]["hit"].map {|h| h["fields"]}
      end
    end
  end
end


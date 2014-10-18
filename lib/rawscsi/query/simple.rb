require "cgi"

module Rawscsi
  module Query
    class Simple
      def initialize(query_string)
        @query_string = query_string
      end

      def build
        "q=#{CGI.escape(@query_string.to_s)}"
      end
    end
  end
end


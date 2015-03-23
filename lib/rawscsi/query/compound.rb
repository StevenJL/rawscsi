module Rawscsi
  module Query
    class Compound
      include Rawscsi::Stringifier::Encode

      attr_reader :query_hash
      def initialize(query_hash)
        @query_hash = query_hash
      end

      def build
        [
          query,
          distance,
          qoptions,
          date,
          sort,
          start,
          limit,
          fields,
          "q.parser=structured"
        ].compact.join("&")
      end

      private
      def query
        "q=" + Rawscsi::Query::Stringifier.new(query_hash[:q]).build
      end

      def date
        return nil unless date_hash = query_hash[:date]
        output_str = "fq="
        date_hash.each do |k,v|
          output_str << "#{k}:#{FRC3339(v)}"
        end
        encode(output_str)
      end

      def FRC3339(date_str)
        return date_str if /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/ =~ date_str
        date_str.gsub(/\d{4}-\d{2}-\d{2}/) do |dt|
          "#{dt}T00:00:00Z"
        end
      end

      def sort
        return nil unless query_hash[:sort]
        encode("sort=#{query_hash[:sort]}")
      end

      def distance
        return nil unless query_hash[:'expr.distance']
        "expr.distance=#{query_hash[:'expr.distance']}"
      end

      def qoptions
        return nil unless query_hash[:qoptions]
        "q.options=#{CGI.escape(query_hash[:qoptions])}"
      end

      def start
        return nil unless query_hash[:start]
        "start=#{query_hash[:start]}"
      end

      def limit
        return nil unless query_hash[:limit]
        "size=#{query_hash[:limit]}"
      end

      def fields
        return nil unless fields_array = query_hash[:fields]
        output = []
        fields_array.each do |field_sym|
          output << field_sym.to_s
        end
        "return=" + output.join(",")
      end
   end
  end
end


module Rawscsi
  module Query
    class Compound
      attr_reader :query_hash
      def initialize(query_hash)
        @query_hash = query_hash
      end

      def build
        [
          query,
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
      "q=" + compound_bool(query_hash[:q])
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

      def compound_bool(hash)
        if compound?(hash)
          stringify_compound(hash)
        else
          stringify_noncompound(hash)
        end
      end

      def compound?(hash) 
        ar = hash.keys
        ar.include?(:and) || ar.include?(:or)
      end

      def stringify_compound(hash)
        bool_op = hash.keys.first
        ar = hash[bool_op]
        "(#{bool_op}" + encode(" #{bool_map(ar)}") + ")"
      end

      def stringify_noncompound(hash)
        if not_hash = hash[:not]
          "(not" + encode(" #{stringify(not_hash)}") + ")"
        elsif range = hash[:range]
          range 
        else
          encode(stringify(hash))
        end
      end

     def bool_map(array)
        output = ""
        array.each do |pred|
          output << compound_bool(pred)
        end
        output
      end

      def stringify(hash)
        output_str = ""
        hash.each do |k,v|
          output_str << "#{k}:'#{v}'"
        end
        output_str
      end

      def encode(str)
        # URI and CGI.escape don't quite work here
        # For example, I need blank space as %20, but they encode it as +
        # So I have to write my own
        str.gsub(' ', '%20').gsub("'", '%27').gsub("[", '%5B').gsub("]",'%5D').gsub("{", '%7B').gsub("}", '%7D')
      end
    end
  end
end


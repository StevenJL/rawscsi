module Rawscsi
  module Stringifier
    class Compound
      include Rawscsi::Stringifier::Encode

      attr_reader :bool_hash

      def initialize(bool_hash)
        @bool_hash = bool_hash
      end

      def build
        bool_op = bool_hash.keys.first
        ar = bool_hash[bool_op]
        "(#{bool_op}" + encode(" #{bool_map(ar)}") + ")"
      end

      private

      def bool_map(value)
        output = ""
        if value.kind_of?(Enumerable)
          value.each do |v|
            output << Rawscsi::Query::Stringifier.new(v).build
          end
        else
          output = Rawscsi::Query::Stringifier.new(v).build
        end
        output
      end
    end
  end
end


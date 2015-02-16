module Rawscsi
  module Query
    class Stringifier
      attr_reader :bool_hash

      def initialize(bool_hash)
        @bool_hash = bool_hash
      end

      def build
        if compound?(bool_hash)
          Rawscsi::Stringifier::Compound.new(bool_hash).build
        else
          Rawscsi::Stringifier::Simple.new(bool_hash).build
        end
      end

      private

      def compound?(value)
        if value.kind_of?(Hash)
          ar = value.keys
          ar.include?(:and) || ar.include?(:or)
        else
          false
        end
      end
    end
  end
end


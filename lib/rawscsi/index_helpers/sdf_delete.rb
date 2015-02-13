module Rawscsi
  module IndexHelpers
    class SdfDelete
      attr_reader :id

      def initialize(id)       
        @id = id
      end
  
      def build
        {
          :type => "delete",
          :id => doc_id
        }
      end

      private
      def doc_id
        if id.kind_of?(String) || id.kind_of?(Numeric)
          id
        elsif id.kind_of?(Hash)
          id[:id]
        else
          "#{id.class}_#{id.id}"
        end
      end
    end
  end
end


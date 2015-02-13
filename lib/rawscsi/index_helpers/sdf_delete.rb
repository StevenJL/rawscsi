module Rawscsi
  module IndexHelpers
    class SdfDelete
      attr_reader :obj_or_id

      def initialize(obj_or_id)       
        @obj_or_id = obj_or_id
      end
  
      def build
        {
          :type => "delete",
          :id => doc_id
        }
      end

      private
      def doc_id
        if obj_or_id.kind_of?(String) || obj_or_id.kind_of?(Numeric)
          obj_or_id
        elsif obj_or_id.kind_of?(Hash)
          obj_or_id[:id]
        else
          "#{obj_or_id.class}_#{obj_or_id.id}"
        end
      end
    end
  end
end


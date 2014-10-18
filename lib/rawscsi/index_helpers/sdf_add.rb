module Rawscsi
  module IndexHelpers
    class SdfAdd
      attr_reader :doc, :attributes

      def initialize(doc, attributes=nil) 
        @doc = doc
        @attributes = attributes || doc.keys
      end
      
      def build
        {
          :id => doc_id,
          :type => "add",
          :fields => fields
        }
      end

      private
      def doc_id
        if doc.is_a?(Hash)
          doc[:id]
        else
          "#{doc.class}_#{doc.id}"
        end
      end

      def fields
        output = {}
        attributes.each do |attr|
          next if attr == :id
          output[attr] = get_attr(doc, attr)
        end
        output
      end

      def get_attr(doc, attr)
        if doc.is_a?(Hash)
          doc[attr]
        else
          doc.send(attr)
        end
      end
    end
  end
end


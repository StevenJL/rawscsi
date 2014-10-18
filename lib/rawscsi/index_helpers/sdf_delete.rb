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
          :id => id
        }
      end
    end
  end
end


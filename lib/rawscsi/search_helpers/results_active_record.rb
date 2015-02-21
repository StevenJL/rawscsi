module Rawscsi
  module SearchHelpers
    class ResultsActiveRecord
      attr_reader :response

      def initialize(response, model)
        @response = response
        @model = model
      end

      def build
        id_array = @response["hits"]["hit"].map {|h| model_id(h["id"]) }
        return [] if id_array.empty?
        results =
          if ActiveRecord::VERSION::MAJOR > 2
            klass.where(:id => id_array).to_a  
          else
            klass.find_all_by_id(id_array)
          end
        results.index_by(&:id).slice(*id_array).values
      end

      private
      def klass
        @model.constantize 
      end

      def model_id(doc_id)
        doc_id.split('_').last.to_i
      end
    end
  end
end


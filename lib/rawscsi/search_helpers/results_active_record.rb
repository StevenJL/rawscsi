module Rawscsi
  module SearchHelpers
    class ResultsActiveRecord
      def initialize(response, model)
        @response = response
        @model = model
      end

      def build
        id_array = @response["hits"]["hit"].map {|h| h["id"].to_i }
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
    end
  end
end


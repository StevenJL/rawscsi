module Rawscsi
  class Base
    attr_accessor :model 
    attr_reader :config, :is_active_record

    def initialize(model_name, options={})
      @is_active_record = options[:active_record]
      @model = model_name
      @config = Rawscsi.registered_models[model_name]
    end
  end
end


$:.unshift(File.expand_path("../", __FILE__))

require "pry"

module Rawscsi
  autoload :Version,       'rawscsi/version'
  autoload :Base,          'rawscsi/base'
  autoload :Search,        'rawscsi/search'
  autoload :Index,         'rawscsi/index'

  module Query
    autoload :Simple,      "rawscsi/query/simple"
    autoload :Compound,    "rawscsi/query/compound"
    autoload :Stringifier,  "rawscsi/query/stringifier"
  end

  module Stringifier
    autoload :Simple,      "rawscsi/stringifier/simple"
    autoload :Compound,    "rawscsi/stringifier/compound"
    autoload :Encode,      "rawscsi/stringifier/encode"
  end

  module SearchHelpers
    autoload :ResultsHash, "rawscsi/search_helpers/results_hash"
    autoload :ResultsActiveRecord, "rawscsi/search_helpers/results_active_record"
  end

  module IndexHelpers
    autoload :Connection,   "rawscsi/index_helpers/connection"
    autoload :SdfDelete,    "rawscsi/index_helpers/sdf_delete"
    autoload :SdfAdd,       "rawscsi/index_helpers/sdf_add"
  end

  @@registered_models = {}

  class Configuration
    attr_accessor :domain_name,
      :domain_id, 
      :region,
      :api_version,
      :attributes,
      :batch_size
  end
  
  def self.register(model)
    config = Configuration.new
    yield(config)
    @@registered_models[model] = config
  end

  def self.registered_models
    @@registered_models
  end
end


require "json"

module Rawscsi
  class Index < Rawscsi::Base
    def upload(obj_array)
      batch_size = 0
      current_batch = []

      obj_array.each do |obj|
        sdf = format_to_sdf(obj)
        size = sdf.to_json.bytesize
        if (batch_size + size) < max_size
          current_batch << sdf
          batch_size = batch_size + size
        else
          post_to_amazon(current_batch)
          current_batch = []
          batch_size = 0
        end
      end
      post_to_amazon(current_batch)
    end

    def delete(id_array)
      if id_array.length < 20000
        delete_from_amazon(id_array)
      else
        id_array.each_slice(20000).to_a.each do |sub_array|
         delete_from_amazon(sub_array)
        end
      end
    end

    private 
    def max_size
      5240000 # bytes
    end

    def format_to_sdf(obj)
      Rawscsi::IndexHelpers::SdfAdd.new(obj, config.attributes).build
    end

    def delete_from_amazon(id_array)
      sdf_del_array = id_array.map do |id|
        Rawscsi::IndexHelpers::SdfDelete.new(id).build
      end
      post_to_amazon(sdf_del_array)
    end

    def post_to_amazon(payload)
      resp = connection.post do |req|
        req.url "#{config.api_version}/documents/batch"
        req.headers["Content-type"] = "application/json"
        req.body = payload.to_json
      end
      resp.body
    end

    def connection
      @connection ||= Rawscsi::IndexHelpers::Connection.new(config).build
    end
  end
end


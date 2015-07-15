module Rawscsi
  class RequestSignature
    def initialize(options)
      required_attributes_missing = []
      require_attribute = lambda do |name|
        return options[name] if options.has_key?(name) 
        required_attributes_missing << name
        nil 
      end
      
      self.secret_key = require_attribute[:secret_key]
      self.access_key_id = require_attribute[:access_key_id]
      self.region_name = require_attribute[:region_name]
      self.endpoint = require_attribute[:endpoint]
      self.method = require_attribute[:method]
      self.host = require_attribute[:host]

      unless required_attributes_missing.size == 0
        raise "#{required_attributes_missing.join(',')} attributes required for a request signature"
      end

      self.debug_mode = options[:debug] || false  
      self.payload = options[:payload] || ''
      self.service_name = options[:service_name] || 'cloudsearch'
      self.headers = extract_headers(options)
      self.query = options[:query] || ''
    end

    def build
      result_headers = default_headers.dup
      result_headers['Authorization'] = "#{algo} Credential=#{access_key_id}/#{credential}, SignedHeaders=#{canonical_headers_names_string}, Signature=#{signature}"

      result = { 
        headers: result_headers, 
      }

      if debug_mode
        result[:debug] = debug_data
      end

      result
    end

    private

    def extract_headers(options)
      return default_headers unless opt_headers = options[:headers] 
      opt_headers.to_h.merge(default_headers)
    end

    def debug_data
      {
        canonical_request: canonical_request,
        payload_digest: payload_digest,
        canonical_request_digest: canonical_request_digest,
        string_to_sign: string_to_sign,
        signature: signature,
        signed_headers: canonical_headers_names_string,
        payload: payload,
      }
    end

    attr_accessor :secret_key,
      :access_key_id, 
      :headers,
      :payload,
      :region_name, 
      :service_name,
      :method,
      :endpoint,
      :query,
      :host,
      :debug_mode

    def signature 
      OpenSSL::HMAC.hexdigest('sha256', signature_key, string_to_sign)
    end
    
    def algo
      'AWS4-HMAC-SHA256'
    end

    def default_headers
      {
        'X-Amz-Date' => amz_datetime,
        'Host' => host,
      }
    end

    def signature_key
      k_date    = OpenSSL::HMAC.digest('sha256', "AWS4" + secret_key, date)
      k_region  = OpenSSL::HMAC.digest('sha256', k_date, region_name)
      k_service = OpenSSL::HMAC.digest('sha256', k_region, service_name)
      k_signing = OpenSSL::HMAC.digest('sha256', k_service, "aws4_request")

      k_signing
    end

    def datetime
      @datetime ||= Time.now.utc
    end

    def amz_datetime
      datetime.strftime('%Y%m%dT%H%M%SZ')
    end

    def date
      datetime.strftime('%Y%m%d')
    end

    def credential
      "#{date}/#{region_name}/cloudsearch/aws4_request"
    end

    def string_to_sign
      [
        algo,
        amz_datetime,
        credential,
        canonical_request_digest,
      ].join("\n")
    end

    def canonical_query_string
      # @NOTE gsubs are here because AWS expects us to escape everything but #encode_www_form encodes space as "+"
      @canonical_query_string = URI.encode_www_form(CGI::parse(query).to_a.sort { |a, b| a.first <=> b.first }).gsub('+', '%20').gsub('*', '%2A')
    end

    def canonical_headers_names_string
      canonical_headers.map(&:first).join(';')
    end

    def canonical_headers
      @canonical_headers ||= headers.to_a.group_by(&:first).map do |name, values|
        canonical_values = values.map(&:last).map do |value|
          value.to_s.first == '"' ? value : value.squeeze(' ')
        end
        [ name.to_s.downcase, canonical_values.join(',') ]
      end.sort { |a, b| a.first <=> b.first }
    end

    def canonical_headers_string
      canonical_headers.map { |header| header.join(':') }.join("\n") + "\n"
    end

    def payload_digest
      @payload_digest ||= OpenSSL::Digest::SHA256.hexdigest(payload) 
    end

    def canonical_request
      @canonical_request ||= [ 
        method,
        endpoint,
        canonical_query_string,
        canonical_headers_string,
        canonical_headers_names_string,
        payload_digest,
      ].join("\n")
    end

    def canonical_request_digest
      @canonical_request_digest ||= OpenSSL::Digest::SHA256.hexdigest(canonical_request)
    end
  end
end

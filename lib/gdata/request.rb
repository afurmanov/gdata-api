require "net/http"
require "net/https"
require 'cgi'

Net::HTTP.version_1_2

module GData
  class Request
    attr_reader :query_url
    def initialize(a_query_url)
      self.url = a_query_url
    end

    def url=(query_url)
      @query_url = query_url
      @query_uri = URI.parse(query_url)
      @http_object = Net::HTTP.new(@query_uri.host, @query_uri.port)
      if @query_uri.scheme == 'https'
        @http_object.use_ssl = true
        @http_object.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end
    
    def use_proxy(address, port, username=nil, password=nil)
      @http_object = Net::HTTP.new(@query_uri.host, @query_uri.port, address, port, username, password) 
    end
    
    def get(header)
      result = process_request(:get, nil, header)
      while result.is_a?(Net::HTTPRedirection)
        if result.is_a?(Net::HTTPNotModified)
          logger.debug "    304:not modified, trying to load cached data"
          return nil
        end
        query = URI::parse(result['location']).query || ""
        Cacher.gsessions!(header.user_id, CGI::parse(query)['gsessionid'].to_s)
        url=result['location']
        result = process_request(:get, nil, header)
      end
      result.body
    end
    
    def put(content, header)
      process_request(:put, content, header).body
    end
    
    def post(content, header)
      process_request(:post, content, header).body
    end

    private
    def process_request(verb, content, header)
      logger.debug( "#{verb.to_s.upcase}: #{@query_url}")
      header = auth_header(header)
      result = nil
      location = UriUtils::merge_query(@query_url, 'gsessionid' => Cacher.gsessions(header.user_id))
      result = @http_object.start do |h| 
        logger.debug "    sending to '#{location}'..."
        logger.debug "    Header:\n#{header.inspect}"
        logger.debug "    Content:\n#{content}" if content
        content\
        ? h.send(verb, location, content, header) \
        : h.send(verb, location, header)
      end

      unless [Net::HTTPSuccess, Net::HTTPRedirection].any? { |k| result.is_a?(k)}
        logger.debug "    #{result} Body:\n#{result.body}"
        raise StandardError.new("HTTP #{verb.to_s.upcase} failed.\n #{result.body}")
      end
      logger.debug "    #{result.code}"
      logger.debug "    Body:\n#{result.body}"
      result
    end
    
    def auth_header(header)
      result = header || {}
      user_auth_token = Cacher.authentication_token(header.user_id)
      if user_auth_token
        result.merge! "Authorization" => "GoogleLogin auth=#{user_auth_token}" 
      end
      result
    end
  end
end

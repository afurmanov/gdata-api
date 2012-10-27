require 'namespaces'

module GData
  class Service
    extend Namespaces
    
    CLIENT_LOGIN_URL = "https://www.google.com/accounts/ClientLogin"
    
    @user_id = nil
    
    class Header < Hash
      attr_reader :user_id
      def initialize(api_version, user_id)
        self["Content-Type"] = "application/atom+xml"
        self["GData-Version"] = api_version
        @user_id = user_id
      end
    end
    
    def self.atom_header(hash = {})
      header = Header.new(namespaces[-1]::API_VERSION, user_id)
      header.merge!(hash)
    end
    
    def self.user_id
      @user_id
    end
    
    def self.feed_entries(options = nil, query = nil)
      query = QueryParams.new unless query #so no check for nil needed further in call stack
      query.validate! if query
      url = feed_url(options || {}, query)
      Cacher.entries(url) do
        logger.debug "Entries for query '#{query}' weren't cached, requesting them..."
        feed_xml =  Request.new(url).get(atom_header)
        feed_class.from_xml(feed_xml).entry
      end
    end
    
    def self.login(user_id)
      @user_id = user_id
      self
    end
    
    def self.authenticate(password)
      Cacher.deauthenticate(user_id)
      request = Request.new(CLIENT_LOGIN_URL)
      source = "fkocherga-gdata-1.0" #just library name and version
      content = "Email=#{CGI::escape(@user_id)}&Passwd=#{CGI::escape(password)}&source=#{CGI::escape(source)}&service=#{service_name}"
      body = request.post(content, atom_header('Content-Type' => 'application/x-www-form-urlencoded'))
      auth_token_re= /Auth=(.+)/
      auth_token = body[auth_token_re, 1]
      Cacher.authentication_token!(user_id, auth_token)
    end
    
    protected
    def self.service_name
      const_get :SERVICE_NAME
    end
    
    def self.feed_url(options, query)
      raise NoMethodError
    end

    #feed used for creating/updating entries
    def self.default_feed_url
      raise NoMethodError
    end
    
    def self.feed_class
      namespaces[-1]::Feed
    end
    
  end
end


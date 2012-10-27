module GData
  module UriUtils
    def self.merge_query(uri, params)
      query = URI::parse(uri).query || ""
      query_params = CGI::parse(query) 
      params.each do |name, value|
        next unless value
        query_params[name] = "#{value}"
      end
      path = uri.gsub /\?.*/, ""
      query = query_params.collect {|p,v| "#{p}=#{CGI::escape(v.to_s)}"} .join("&")
      "#{path}?#{query}"
    end
  end
end

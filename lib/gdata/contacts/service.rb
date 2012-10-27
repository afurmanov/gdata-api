module GData
  module Contacts
    class Service < GData::Service
      SERVICE_NAME = "cp"
      
      private
      #Options:
      #  :projection => one of :full, :thin, :property_key
      #  :user_id => :default, "user@site.com"
      def self.feed_url(options, query)
        projection = options.delete(:projection) || :full
        raise ArgumentError, "User ID has to be specified for calendar feed" unless user_id
        "http://www.google.com/m8/feeds/contacts/#{CGI::escape(user_id)}/#{projection}#{query}"
      end
      
      def self.feed_class
        Feed
      end
      
      def self.default_feed_url
        feed_url({:projection => :full}, nil)
      end
    end #Service
  end
end


module GData
  module Calendar
    class Service < GData::Service
      
      SERVICE_NAME = "cl"
      private
      #Options:
      #  :magic_cookie => ...
      #  :project => one of :full, :basic
      #  :visibility => :private, :public, "magic-cookie"
      #  :projection => :full, :full_noattendees, :composite, :attendees_only, :free_busy, :basic
      #  :user_id => :default, "user@site.com"
      def self.feed_url(options, query)
        magic_cookie = options.delete(:magic_cookie)
        visibility = magic_cookie && !options[:visiblity] \
        ? :private \
        : options.delete(:visibility) || :public
        projection = options.delete(:projection) || :full
        raise ArgumentError, "User ID has to be specified for calendar feed" unless user_id
        magic_cookie\
        ? "http://www.google.com/calendar/feeds/#{user_id}/#{visibility}-#{magic_cookie}/#{projection}#{query}"\
        : "http://www.google.com/calendar/feeds/#{user_id}/#{visibility}/#{projection}#{query}"\
      end
      
      def self.feed_class
        Feed
      end
      
      def self.default_feed_url
        feed_url({:projection => :full, :visibility => :private}, nil)
      end
    end
  end
end


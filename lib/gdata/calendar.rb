require 'gdata'

module GData
  module Calendar
    XML_NAMESPACE = {"gCal" => "http://schemas.google.com/gCal/2005"}
    API_VERSION = "2.1"
    
    autoload :Event, 'gdata/calendar/event'
    autoload :Feed, 'gdata/calendar/feed'
    autoload :QueryParams, 'gdata/calendar/query_params'
    autoload :Service, 'gdata/calendar/service'
  end
end




module GData
  module Contacts
    class Feed < GData::Feed
      elements "atom:entry*" => Contact
    end
  end
end

    

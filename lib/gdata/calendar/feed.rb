module GData
  module Calendar
    class Feed < GData::Feed
      elements 'atom:entry*' => Event
    end
  end
end

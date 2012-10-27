module GData
  class Event < Entry
    ATTENDEE_KIND = "http://schemas.google.com/g/2005#event.attendee"
    
    elements 'gd:comments?', 'gd:eventStatus?', 'gd:recurrence?', 'gd:transperancy?', 'gd:visibility?'
    elements 'gd:where*' => Where, 'gd:who*' => Who, 'gd:when*' => When
    
    def category_kind; "http://schemas.google.com/g/2005#event"; end
    def start_time; self.when[0].startTime; end
    def start_time=(value);self.when[0].startTime = value; end
    def end_time; return self.when[0].endTime; end
    def end_time=(value); self.when[0].endTime = value; end
    def joined_attendees
      author_email = self.author[0].email 
      self.who.select { |w| w.email != author_email }
    end
  end
end

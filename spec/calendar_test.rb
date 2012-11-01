require File.expand_path(File.dirname(__FILE__)+ '/test_helper')

require 'gdata/calendar'

describe "GData Calendar Test" do
  describe "calendar feed" do
    before :each do
      GData::Cacher.clear
      GData::Calendar::Service.login(USER_ID).authenticate(PASSWORD)
      # GData::Calendar::Service.delete_feed(:visibility=>:private)
      # GData::Calendar::Service.create_feed(:visibility=>:private)
      # event = GData::Calendar::Event.new
      # event.start_time = DateTime.now
      # event.end_time = DateTime.now + 1.hour
      # event.recurring = :every_day
      # event.title = "Oil Painting"
      # event.save!
    end
    
    it "should fetch some entries" do
      debugger
      entries = GData::Calendar::Service.feed_entries(:visibility=>:private)
      debugger
      entries.size.should > 0 
    end

    describe "next week events" do
      before :each do 
        query = GData::Calendar::QueryParams.new 
        @tomorrow = Date.today + 1
        query[:start_min] = @tomorrow
        query[:start_max] = @tomorrow + 7
        @events = GData::Calendar::Service.feed_entries({:visibility => :private}, query)
        @events.size.should > 0
        @tomorrow_event = @events[0]
      end
      
      it "should fetch 7 events for next week" do
        assert_equal 7, @events.size
      end
      
      it "should fetch feed from _cache_ after receiving 304 status" do
        event = @events[0]
        event.reload!
        #only one http request returning Not Modified status
        mock.proxy(Net::HTTP).new.with_any_args do |http_object|
          mock.proxy(http_object).send.with_any_args
        end
       mock.proxy(Net::HTTPNotModified).new.with_any_args
       dont_allow(Net::HTTPSuccess).new
       event.reload!
      end
      
      it "should have correct field values" do
        @events.size.should > 0
        @tomorrow_event.title.should == "Oil Painting"
        tomorrow_10_am = DateTime.parse("#{@tomorrow.year}-#{@tomorrow.month}-#{@tomorrow.day}T10:00:00.000+04:00")
        tomorrow_11_am = DateTime.parse("#{@tomorrow.year}-#{@tomorrow.month}-#{@tomorrow.day}T11:00:00.000+04:00")
        @tomorrow_event.start_time.to_s.should ==  tomorrow_10_am.to_s
        @tomorrow_event.end_time.to_s.should == tomorrow_11_am.to_s
      end
      
      it "should save tomorrow's event" do
        old_time = DateTime.parse("#{@tomorrow.year}-#{@tomorrow.month}-#{@tomorrow.day}T10:00:00.000+04:00")
        new_time = DateTime.parse("#{@tomorrow.year}-#{@tomorrow.month}-#{@tomorrow.day}T10:10:00.000+04:00")
        @tomorrow_event.start_time = new_time
        updated = @tomorrow_event.updated
        @tomorrow_event.start_time.should == new_time
        @tomorrow_event.save!
        @tomorrow_event.updated.should_not == updated 
        @tomorrow_event.start_time.shlould == new_time
        @tomorrow_event.start_time = old_time
        @tomorrow_event.save!
        @tomorrow_event.start_time.should == old_time
      end
      
      it "should be possible to add and remove attendee" do

        @tomorrow_event.who.size.should ==  1
        first_attendee = @tomorrow_event.who[0]
        first_attendee.email.should == USER_ID
        
        email = "fkocherga@gmail.com"
        new_attendee = GData::Who.new
        new_attendee.email = email
        new_attendee.rel = GData::Event::ATTENDEE_KIND
        new_attendee.valueString = "Fedor Kocherga"
        @tomorrow_event.who.push(new_attendee)
        @tomorrow_event.save!
        @tomorrow_event.who.size.should == 2
        emails = @tomorrow_event.who.collect { |w| w.email}
        emails.should =~ [USER_ID, email]
        
        @tomorrow_event.who.clear
        @tomorrow_event.save!
        @tomorrow_event.who.size.should ==  1
        first_attendee = @tomorrow_event.who[0]
        first_attendee.email.should == USER_ID  #actually it is organizer, not an attendee
      end
    end
  end
end


require File.expand_path(File.dirname(__FILE__)+ '/test_helper')

require 'gdata/calendar'

class GCalendarTest < Test::Unit::TestCase
  def assert_not_empty(str)
    assert_not_nil str
    assert_not_same "", str
  end

  context "calendar feed" do
    setup do
      GData::Cacher.clear
      GData::Calendar::Service.login(USER_ID).authenticate(PASSWORD)
#       GData::Calendar::Service.delete_feed(:visibility=>:private)
#       GData::Calendar::Service.create_feed(:visibility=>:private)
#       event = GData::Calendar::Event.new
#       event.start_time = DateTime.now
#       event.end_time = DateTime.now + 1.hour
#       event.recurring = :every_day
#       event.title = "Oil Painting"
#       event.save!
    end
    
    should "fetch some entries" do
      entries = GData::Calendar::Service.feed_entries({:visibility=>:private})
      assert entries.size > 0 
    end

    context "next week events" do
      setup do 
        query = GData::Calendar::QueryParams.new 
        @tomorrow = Date.today + 1
        query[:start_min] = @tomorrow
        query[:start_max] = @tomorrow + 7
        @events = GData::Calendar::Service.feed_entries({:visibility => :private}, query)
        assert @events.size > 0
        @tomorrow_event = @events[0]
      end
      
      should "fetch 7 events for next week" do
        assert_equal 7, @events.size
      end
      
      should "fetch feed from _cache_ after receiving 304 status" do
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
      
      should "have correct field values" do
        assert @events.size > 0
        assert_equal "Oil Painting", @tomorrow_event.title
        tomorrow_10_am = DateTime.parse("#{@tomorrow.year}-#{@tomorrow.month}-#{@tomorrow.day}T10:00:00.000+04:00")
        tomorrow_11_am = DateTime.parse("#{@tomorrow.year}-#{@tomorrow.month}-#{@tomorrow.day}T11:00:00.000+04:00")
        assert_equal tomorrow_10_am.to_s, @tomorrow_event.start_time.to_s
        assert_equal tomorrow_11_am.to_s, @tomorrow_event.end_time.to_s
      end
      
      should "save tomorrow's event" do
        old_time = DateTime.parse("#{@tomorrow.year}-#{@tomorrow.month}-#{@tomorrow.day}T10:00:00.000+04:00")
        new_time = DateTime.parse("#{@tomorrow.year}-#{@tomorrow.month}-#{@tomorrow.day}T10:10:00.000+04:00")
        @tomorrow_event.start_time = new_time
        updated = @tomorrow_event.updated
        assert_equal new_time, @tomorrow_event.start_time
        @tomorrow_event.save!
        assert_not_equal updated, @tomorrow_event.updated
        assert_equal new_time, @tomorrow_event.start_time
        @tomorrow_event.start_time = old_time
        @tomorrow_event.save!
        assert_equal old_time, @tomorrow_event.start_time
      end
      
      should "be possible to add and remove attendee" do

        assert_equal 1, @tomorrow_event.who.size
        first_attendee = @tomorrow_event.who[0]
        assert_equal USER_ID, first_attendee.email
        
        email = "fkocherga@gmail.com"
        new_attendee = GData::Who.new
        new_attendee.email = email
        new_attendee.rel = GData::Event::ATTENDEE_KIND
        new_attendee.valueString = "Fedor Kocherga"
        @tomorrow_event.who.push(new_attendee)
        @tomorrow_event.save!
        assert_equal 2, @tomorrow_event.who.size
        emails = @tomorrow_event.who.collect { |w| w.email}
        assert_same_elements [USER_ID, email], emails
        
        @tomorrow_event.who.clear
        @tomorrow_event.save!
        assert_equal 1, @tomorrow_event.who.size
        first_attendee = @tomorrow_event.who[0]
        assert_equal USER_ID, first_attendee.email #actually it is organizer, not an attendee
      end
    end
  end
end


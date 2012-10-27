require File.expand_path(File.dirname(__FILE__)+ '/test_helper')

require 'gdata/contacts'

class GContactsTest < Test::Unit::TestCase
  
  context "having contact feed" do
    setup do
      GData::Cacher.clear
      GData::Contacts::Service.login(USER_ID).authenticate(PASSWORD)
    end
    
    should "be able to fetch some entries" do
      entries = GData::Contacts::Service.feed_entries
      assert entries.size > 0 
    end
    
    should "be able to create new contact" do
      first_name = "Vasya"
      second_name = "Petrov"
      full_name = "#{first_name} #{second_name}"
      phone = "8127777777"
      contact = GData::Contacts::Contact.new
      contact.name = GData::Name.new
      contact.name.givenName = first_name
      contact.name.familyName = second_name
      contact.title = full_name
      phoneNumber = GData::PhoneNumber.new
      phoneNumber.text = phone
      phoneNumber.rel = "http://schemas.google.com/g/2005#home"
      contact.phoneNumber.push(phoneNumber)
      assert_nothing_raised { contact.save! }
      assert !contact.phoneNumber.empty?
      assert !contact.link_to_self.empty?
      contact.phoneNumber.clear
      contact.reload!
      assert_equal phone, contact.phoneNumber[0].text
#       contact.delete
#       assert_raise StandardError do contact.phoneNumber[0].text = phone 
    end
  end
  
end


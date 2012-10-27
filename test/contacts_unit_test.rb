require File.expand_path(File.dirname(__FILE__)+ '/test_helper')

require 'gdata/contacts'

include GData

class GConctactsUnitTest < Test::Unit::TestCase
  should "generate correct contact xml" do
    contact = GData::Contacts::Contact.new
    contact.name = Name.new
    contact.name.givenName = "Vasya"
    contact.name.familyName = "Petrov"
    contact.title = 'Vasya Petrov'
    contact.id = '1'
    contact.updated = DateTime.now
    xml_node = contact.to_xml
    nokogiri_xml_node = Nokogiri::XML(xml_node)
    assert_equal 1, nokogiri_xml_node.xpath("/atom:entry").size
    assert_equal 1, nokogiri_xml_node.xpath( "/atom:entry/atom:category").size
    assert_equal 1, nokogiri_xml_node.xpath("/atom:entry/gd:name/gd:givenName").size
    assert_equal "Vasya", nokogiri_xml_node.xpath("/atom:entry/gd:name/gd:givenName")[0].content
    assert_equal "Petrov", nokogiri_xml_node.xpath("/atom:entry/gd:name/gd:familyName")[0].content
    
    new_contact = GData::Contacts::Contact.from_xml(xml_node)
    assert_equal GData::Name, new_contact.name.class
    assert_equal "Vasya", new_contact.name.givenName
    assert_equal "Petrov", new_contact.name.familyName
  end
end

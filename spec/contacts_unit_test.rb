require File.expand_path(File.dirname(__FILE__)+ '/test_helper')

require 'gdata/contacts'

include GData

describe  "GData Contacts" do
  it "should generate correct contact xml" do
    contact = GData::Contacts::Contact.new
    contact.name = Name.new
    contact.name.givenName = "Vasya"
    contact.name.familyName = "Petrov"
    contact.title = 'Vasya Petrov'
    contact.id = '1'
    contact.updated = DateTime.now
    xml_node = contact.to_xml
    nokogiri_xml_node = Nokogiri::XML(xml_node)
    nokogiri_xml_node.xpath("/atom:entry").size.should == 1
    nokogiri_xml_node.xpath( "/atom:entry/atom:category").size.should == 1
    nokogiri_xml_node.xpath("/atom:entry/gd:name/gd:givenName").size.should == 1
    nokogiri_xml_node.xpath("/atom:entry/gd:name/gd:givenName")[0].content.should == "Vasya"
    nokogiri_xml_node.xpath("/atom:entry/gd:name/gd:familyName")[0].content.should == "Petrov"
    
    new_contact = GData::Contacts::Contact.from_xml(xml_node)
    new_contact.name.class.should == GData::Name
    new_contact.name.givenName.should == "Vasya"
    new_contact.name.familyName.should == "Petrov"
  end
end

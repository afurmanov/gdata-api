
# Deprecated
 *see [Google Developer Guide Warning](https://developers.google.com/gdata/docs/developers-guide)*

## Google Data API *v2.0* Ruby client library

## Usage example:
 
    GData::Calendar::Service.login(USER_ID).authenticate(PASSWORD)
    GData::Calendar::Service.create_feed(:visibility=>:private)
    event = GData::Calendar::Event.new
    event.start_time = DateTime.now
    event.end_time = DateTime.now + 1.hour
    event.recurring = :every_day
    event.title = "Oil Painting"
    event.save!

## Wrapping Google Data API 2.0:
  The librarary provide a DSL to map Google Data API  to Ruby code, 
  For example [Google Contact specification](https://developers.google.com/gdata/docs/2.0/elements#gdContactKind) could be implemented like:

    module GData
      module Contacts
        class Contact < GData::Entry
          def category_kind; "http://schemas.google.com/contact/2008#contact"; end
          elements 'gd:email*'=>GData::Email, 'gd:phoneNumber*'=>GData::PhoneNumber, 'gd:name?'=>GData::Name
          #...
        end
      end
    end


  The *elements* method would generate accessors:
  
     GData::Contacts::Contact#email         #Array of GData::Email
     GData::Contacts::Contact#phoneNumber   #Array of GData::PhoneNumber
     GData::Contacts::Contact#name          #GData::Name
     GData::Contacts::Contact#name=
     GData::Contacts::Contact#name?

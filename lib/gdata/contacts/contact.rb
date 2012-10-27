module GData
  module Contacts
    class Contact < GData::Entry
      def category_kind; "http://schemas.google.com/contact/2008#contact"; end
      elements 'gd:email*'=>GData::Email, 'gd:phoneNumber*'=>GData::PhoneNumber, 'gd:name?'=>GData::Name
      #these elements not implemented yet(todo)
      #elements :groupMembershipInfo=>GroupMembershipInfo
      #elements :im=>IM, :postalAddress=>PostalAddress, :organization=>Organization
      #elements :extended_property=>ExtendedProperty
      #elements :deleted=>???
    end
  end
end

  

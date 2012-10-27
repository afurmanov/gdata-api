require 'gdata'

module GData
  module Contacts
    XML_NAMESPACE = {"gd" => 'http://schemas.google.com/g/2005'}
    API_VERSION = "3.0"

    autoload :Contact, 'gdata/contacts/contact'
    autoload :Feed, 'gdata/contacts/feed'
    autoload :QueryParams, 'gdata/contacts/query_params'
    autoload :Service, 'gdata/contacts/service'
  end
end

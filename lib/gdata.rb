# require 'atom'
# require 'time'
# require 'cgi'

module GData
  module Atom
    XML_NAMESPACE = {"atom" => 'http://www.w3.org/2005/Atom'}
    autoload :Base, 'gdata/atom/base'
    autoload :Entry, "gdata/atom/entry"
    autoload :Feed, 'gdata/atom/feed'
    autoload :Link, "gdata/atom/link"
    autoload :Author, "gdata/atom/author"
    autoload :Category, "gdata/atom/category"
    autoload :ElementWithId, 'gdata/atom/element_with_id'
  end
  
  API_VERSION = "2.1"
  XML_NAMESPACE = {"gd" => 'http://schemas.google.com/g/2005'}
  autoload :Email, 'gdata/email'
  autoload :Entry, 'gdata/entry'
  autoload :Event, 'gdata/event'
  autoload :Feed, 'gdata/feed'
  autoload :Name, 'gdata/name'
  autoload :PhoneNumber, 'gdata/phone_number'
  autoload :QueryParams, 'gdata/query_params'
  autoload :Service, 'gdata/service'
  autoload :When, 'gdata/when'
  autoload :Where, 'gdata/where'
  autoload :Who, 'gdata/who'
  autoload :Request, 'gdata/request'
  autoload :Cacher, 'gdata/cacher'
  autoload :UriUtils, 'gdata/uriutils'
end

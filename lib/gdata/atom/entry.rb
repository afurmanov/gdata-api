module GData
  module Atom
    class Entry < ElementWithId
      elements 'atom:content?', 'atom:published?'
      def self.xml_tag; "atom:entry"; end
      #XML_NAMESPACE = {"atom" => "http://www.w3.org/2005/Atom"}
    end
  end
end

module GData
  module Atom
    class Entry < ElementWithId
      elements 'atom:content?', 'atom:published?'
      def self.xml_tag; "atom:entry"; end
    end
  end
end

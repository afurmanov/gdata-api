module GData
  module Atom
    class Feed < ElementWithId
      elements 'atom:generator?', 'atom:icon?', 'atom:entry*' => Entry
      def self.xml_tag; "atom:feed"; end
    end
  end
end

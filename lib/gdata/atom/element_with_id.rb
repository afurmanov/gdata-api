require 'nokogiri'

module GData
  module Atom
    class ElementWithId < Base
      elements 'atom:id'
      elements 'atom:title', 'atom:author*' => Author, 'atom:category*' => Category
      elements 'atom:contributor*', 'atom:summary?'
      elements 'atom:updated' => DateTime, 'atom:link*' => Link
      
      def exists?
        !self.id.empty?
      end
      
      def link_to_self
        found = link.find { |l| l.rel == 'self' }
        return nil unless found
        found.href
      end
      
      def from_hash(hash)
        hash.delete("link_to_self") if hash
        super(hash)
      end
      
      def to_hash
        result = super
        result.merge "link_to_self" => link_to_self
      end
      
      def to_xml
        super self.class.xml_tag
      end
      
      def self.from_xml(xml)
        logger.info("reading #{xml_tag} from xml...")
        xml_node = Nokogiri::XML(xml)
        result = from_xml_node(xml_node, xml_tag, xml_node.namespaces["xmlns"])
        logger.info("reading #{xml_tag} from xml - done.")
        result
      end
      
      def self.xml_tag
        raise NoMethodError
      end
    end
  end
end

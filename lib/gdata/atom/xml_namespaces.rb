module GData
  module Atom

    module XmlNamespaces
      include Namespaces
      
      def xml_namespaces
        return @xml_namespaces if @xml_namespaces
        @xml_namespaces = {}
        ancestors = self.ancestors.select {|a| a.class == Class}
        ancestors -= [Object, Object.superclass]
        namespaces = ancestors.map(&:namespaces).flatten.uniq
        namespaces.each { |nm|  @xml_namespaces.merge! nm::XML_NAMESPACE }
        @xml_namespaces
      end
      
    end
  end
end  

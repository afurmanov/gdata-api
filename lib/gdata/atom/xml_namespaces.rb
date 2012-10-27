module GData
  module Atom

    module XmlNamespaces
      include Namespaces
      
      def xml_namespaces
        return @xml_namespaces if @xml_namespaces
        @xml_namespaces = {}
        klass = self
        loop do
          @xml_namespaces.merge! klass.namespaces[-1]::XML_NAMESPACE
          klass = klass.superclass
          break if klass > Base
        end
        @xml_namespaces
      end
      
    end
  end
end  

require 'namespaces'
require 'gdata/atom/xml_namespaces'

module GData
  module Atom
    Base = Class.new(Object) do#Class.new(BasicObject) do
      extend XmlNamespaces
      include Namespaces

      def from_hash(hash)
        all_field_infos = self.class.all_field_infos
        hash.each do |field, value|
          field_info = all_field_infos[field] 
          if field_info #only fields we understand
            klass = value.delete("class") if value.is_a? Hash
            v = klass ? eval(klass).new.from_hash(value) : value
            v = DateTime.parse(v) if field_info[:class] <= DateTime
            if field_info[:is_array]
              value.each { |e| send("#{field}").push(self.class.from_hash(e))}
            else
              send("#{field}=", v )
            end
          end
        end
        self
      end
      
      def to_hash
        result = {"class" => self.class.to_s}
        self.class.all_field_infos.each do |field, info|
          value = send(field)
          next if !value || value.respond_to?(:empty?) && value.empty?
          case value
            when Base; value = value.to_hash
            when Array; value = value.collect {|v| v.to_hash}
            when DateTime; value = value.to_s
          end
          result[field] = value
        end
        result
      end
      
      def self.from_hash(hash)
        logger.debug "constructing '#{self}' from hash..."
        klass = hash.delete("class")
        logger.debug "hash : #{hash.inspect}"
        raise StandardError, "Cannot construct '#{self.class}' from hash, 'cause it misses the 'class' key." unless klass
        result = eval(klass).new.from_hash(hash)
        logger.debug "constructing '#{self}' from hash...done"
        result
      end
      
      def to_xml(node_name)
        do_to_xml(node_name, {}, true)
      end
      
      #private
      def do_to_xml(node_name, xml_namespaces, top_level_node = false)
        xml_namespaces.merge!(self.class.xml_namespaces)
        
        subnodes_xml = ""
        self.class.node_fields.each do |field, info|
          value = send(field)
          next if !value || value.respond_to?(:empty?) && value.empty?
          if info[:is_text]
            subnodes_xml << value
            next
          end
          values = value.is_a?(Array) ? value : [value]
          values.each do |val|
            subnodes_xml << (val.is_a?(Base) \
                             ? val.do_to_xml(info[:node_name], xml_namespaces)\
                             : "<#{info[:node_name]}>#{self.class.convert_to_xml(val)}</#{info[:node_name]}>")
          end
        end

        xml = ""
        xml << "<#{node_name} "
        #attributes, xml_namespaces go first
        xml_namespaces.each { |namespace, url| xml << " xmlns:#{namespace}='#{url}' " } if top_level_node
        self.class.attribute_fields.each do |field, info|
          value = send(field)
          next if !value || value.respond_to?(:empty?) && value.empty?
          xml << "#{info[:node_name]} = '#{self.class.convert_to_xml(value)}' "
        end
        xml << ">"
        xml << subnodes_xml
        xml << "</#{node_name}>"
        xml
      end #to_xml
    end  #instance methods
    
    Base.instance_eval do #class methods
      def self_field_infos
        @field_infos ||= {}
        @field_infos
      end

      def all_field_infos
        if self.superclass.respond_to? :all_field_infos
          return self.superclass.all_field_infos.merge(self_field_infos)
        else
          return self_field_infos
        end
      end
      
      def node_fields
        all_field_infos.select { |field, info| !info[:is_attribute]}
      end
      
      def attribute_fields
        all_field_infos.select { |field, info| info[:is_attribute]}
      end
      
      def generate_field_accessor(field_spec, klass)
        is_optional = '?' == field_spec[-1,1]
        is_array = '*' == field_spec[-1,1]
        is_attribute = '@' == field_spec[0,1]
        is_text = "text()" == field_spec
        node_name = field_spec
        node_name = node_name[0..-2] if is_optional || is_array 
        node_name = node_name[1..-1] if is_attribute
        node_name = "text" if is_text

        field = node_name.gsub /.*:/, ""
        var_name = "@#{field}"
        
        self_field_infos[field] = {:node_name => node_name, 
          :class => klass, 
          :is_attribute => is_attribute, 
          :is_array => is_array, 
          :is_optional => is_optional, 
          :is_text => is_text,
          :var_name => var_name }
        
        define_method(field) do
          result = instance_variable_get(var_name)
          return result if result
          return nil if is_optional
          if is_array
            array = Array.new
            instance_variable_set(var_name, array)
            return array
          end
          ""
        end

        define_method("#{field}?") do
          send("#{field}".to_sym)
        end if is_optional
        
        define_method("#{field}=".to_sym) do |value|
          instance_variable_set(var_name, value)
        end if !is_array

      end #generate_field_accessor()
      
      def elements(*elements)
        elements.each do |field|
          case field
          when String;
              generate_field_accessor(field, String)
          when Hash;
              field.each {|f, klass| generate_field_accessor(f, klass)}
          end
        end
      end
      
      def convert_to_xml(value)
        case value
        when Time;
            value = value.iso8601
        end
        value
      end

      def from_xml_element(klass, xml_element, default_xml_namespace)
        if klass == String
          return xml_element.content
        elsif klass < Base
          return klass.from_xml_node(xml_element, nil, default_xml_namespace)
        elsif klass == DateTime
          return DateTime.parse(xml_element.content)
        else
          raise ArgumentError, "Cannot parse xml elemento into class '#{klass}'"
        end
      end

      def change_xml_namespaces_to_default(field_path, default_xml_namespace)
        return field_path unless default_xml_namespace
        xml_namespaces.each do |k,v| 
          if v == default_xml_namespace
            return field_path.gsub("#{k}:", "xmlns:")
          end
        end
        field_path
      end
      
      def from_xml_node(xml_node, path = nil, default_xml_namespace = nil)
        logger.debug("from_xml_node(): '#{path}'\n #{xml_node}")
        result = self.new
        all_field_infos.each do |field, info|
          field_path = "#{info[:node_name]}"
          field_path = "@#{field_path}" if info[:is_attribute]
          field_path = "#{field_path}()" if info[:is_text]
          field_path = "#{path}/#{field_path}" if path
          field_path = change_xml_namespaces_to_default(field_path, default_xml_namespace)
          var_name = info[:var_name]
          node_class = info[:class]
          logger.debug("field_path: '#{field_path}'")
          if info[:is_array] 
            logger.debug("field is array")
            values = []
            xml_node.xpath(field_path).each { |node| values.push(from_xml_element(node_class, node, default_xml_namespace)) }
            result.instance_variable_set(var_name, values) unless values.empty?
          else
            is_required = !info[:is_optional] && !info[:is_text]
            logger.debug("field is not array and 'is_required == #{is_required}'")
            value = xml_node.xpath(field_path)
            logger.debug("xpath('#{field_path}'): #{value.size}} elements")
            raise RuntimeError, "XML must have at most one value for path '#{field_path}'" if value.size > 1
            raise RuntimeError, "XML must have exactly one value for path '#{field_path}'" if 0 == value.size && is_required
            next if 0 == value.size
            value = from_xml_element(node_class, value[0], default_xml_namespace)
            result.instance_variable_set(var_name, value)
          end
        end
        result
      end #from_xml_node
    end #class methods
    
  end
end  

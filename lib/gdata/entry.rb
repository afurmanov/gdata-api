module GData
  class Entry < Atom::Entry
    elements "@gd:etag?" #required?
    
    def initialize
      category = Atom::Category.new
      category.scheme = 'http://schemas.google.com/g/2005#kind'
      category.term = category_kind
      self.category.push category
    end
    
    def save!(options = {})
      entry_xml = ""
      if exists?
        request = GData::Request.new(link_to_self)
        #todo: use this option
        ignore_newer_version = options.delete(:ignore_newer_version) || false
        header = service_class.atom_header
        header["If-Match"] = "*"
        entry_xml = request.put(to_xml, service_class.atom_header)
      else
        request = GData::Request.new(service_class.default_feed_url)
        entry_xml = request.post(to_xml, service_class.atom_header)
      end
      reload_from_xml!(entry_xml)
    end
    
    def reload!(a_url = nil)
      url = a_url || link_to_self
      entry = GData::Cacher.entry(url) #10 min hardcoded for now
      header = service_class.atom_header
      request = GData::Request.new(url)
      header.merge! "If-None-Match" => entry.etag if entry && !entry.etag.empty?
      entry_xml = request.get(header)
      if !entry_xml
        from_entry!(entry)
        return self
      end
      reload_from_xml!(entry_xml)
      self
    end
    
    def reload_from_xml!(xml)
      entry =  self.class.from_xml(xml)
      from_entry!(entry)
      GData::Cacher.entry!(link_to_self, self)
      self
    end
    
    def from_entry!(entry)
      self.class.all_field_infos.each do |field, info|
        var_name = info[:var_name]
        instance_variable_set(var_name, entry.instance_variable_get(var_name))
      end
    end
    
    private
    def service_class
      namespaces[-1]::Service
    end
    
    #     def delete!(options = {})
    #       #todo: implement
    #       ignore_newer_version = options.delete(:ignore_newer_version) || false
    #     end
  end
end

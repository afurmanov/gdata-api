require 'nokogiri'

module GData

  #http://code.google.com/apis/gdata/docs/2.0/reference.html
  #If the requested feed is in the Atom format, if no query 
  #parameters are specified, and if the result doesn't contain 
  #all the entries, the following element is inserted into 
  #the top-level feed: <link rel="next" type="application/atom+xml" href="..."/>. 
  #It points to a feed containing the next set of entries.
  class Feed < Atom::Feed
    elements "@gd:etag?" #required?

    protected
    #     def self.creates_entries_of_kind(klass)
    #       define_method :create_entry do |entry_data|
    #         klass.from_xml_node(entry_data)
    #       end
    #     end
    #     creates_entries_of_kind Entry
    
    private 
    #     def each_entry
    #       #note! Even 'If-None-Match' => Etag added to header it does not
    #       #lead to 304(Not Modified) reply. Todo: figure out why and is it always behaves this way?
    #       feed_chunk = @fetcher.get(self.class.atom_header)
    #       @xml = Nokogiri::XML(feed_chunk).search('feed')[0]
    #       @xml.search('entry').each do |e|
    #         yield e
    #       end
    #       etag = self.etag
    #       next_chunk_url = @xml.search('feed/link[@rel="next"]')
    #       return nil if next_chunk_url.empty?
    #       @fetcher.url = next_chunk_url[0][:href]
    #     end
    
    #     def feed_url(query = nil)
    #       query.validate! if query
    #     end
  end #Feed
end

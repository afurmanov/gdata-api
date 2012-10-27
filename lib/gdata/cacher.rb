module GData
  class Cacher
    class <<self
      def init(cache)
        @cache = cache
        @gsessions = @cache.collection("gsessions")
        @entries = @cache.collection("entries")
        @queries = @cache.collection("queries")
      end
      
      def clear()
        @cache.collections.select{ |c| c.name != 'system.indexes' }.each { |c| c.drop }
      end
      
      def deauthenticate(user_id)
        @gsessions.remove("user_id" => user_id)
      end
    
      def authentication_token(user_id)
        user_gsession = @gsessions.find_one("user_id" => user_id)
        user_gsession ? user_gsession["Auth"] : nil
      end
      
      def authentication_token!(user_id, token)
        @gsessions.update( { "user_id" => user_id}, { "$set" => { "user_id" => user_id, "Auth" => token }}, :upsert => true)
      end
      
      def gsessions(user_id)
        user_gsession = @gsessions.find_one("user_id" => user_id)
        user_gsession ? user_gsession["gsession_id"] : nil
      end
      
      def gsessions!(user_id, gsession_id)
        @gsessions.update( { "user_id" => user_id}, { "$set" => { "user_id" => user_id, "gsession_id" => gsession_id }}, :upsert => true)
      end
      
      def entry(url)
        hash = @entries.find_one({"link_to_self" => url})
        return nil unless hash
        GData::Atom::Base.from_hash(hash)
      end
      
      def entry!(url, a_entry)
        logger.info "updating entry '#{url}', new etag: '#{a_entry.etag}'"
        @entries.update({"link_to_self" => url}, a_entry.to_hash, :upsert => true)
      end
      
      def entries(url)
        logger.info "Checking wether query '#{url}' is cached"
        query = @queries.find_one({ "url" => url})
        result = nil
        if query
          logger.info "Found query in cache, checking whether we can use its result"
          #check if stored ids and etags are same as in 'entries' collection
          entries = @entries.find({"id" => { "$in" => query["result_ids"] }} ).to_a
          entries_ids = entries.collect {|e| e["id"]}
          logger.debug "query['result_ids'].size = #{query["result_ids"].size}, total entries with these ids = #{entries_ids.size} "
          if entries_ids.size == query["result_ids"].size
            entries_etags = entries.collect { |e| e["etag"]}.sort
            etags_are_same = entries_etags == query["result_etags"].sort
            if etags_are_same
              logger.info "Entries fetched from cache." 
              return entries.collect {|h| GData::Atom::Base.from_hash(h)}
            else
              logger.info "Etags for cached query results and for entries are different. Cannot use cached entries."
            end
          end
        end

        logger.info "Either query was not cached or its result obsoleted, requesting the data"
        result = yield
        entries_ids = result.collect { |e| e.id}
        entries_etags = result.collect { |e| e.etag}
        @queries.update( { "url" => url}, 
                         { "url" => url, "result_ids" => entries_ids, "result_etags" => entries_etags}, :upsert => true )
        logger.info "Queries cache is updated for query '#{url}'"
        result.each do |entry|
          @entries.update( { "id" => entry.id }, entry.to_hash, :upsert => true )
        end
        logger.info "Entries cache was updated"
        result
      end
      
    end
  end
end

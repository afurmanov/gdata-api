module GData
  module Contacts
    class QueryParams < GData::QueryParams
      describe_params :alt=>String, :max_results => Integer
      describe_params :start_index => Integer, :updated_min => :date_or_time
      describe_params :orderby => ["lastmodified"], :showdeleted => :boolean
      describe_params :sortorder => ["ascending", "descending"]
      describe_params :group => String
    end
  end
end

    

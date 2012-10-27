module GData
  module Calendar
    class QueryParams < GData::QueryParams
      describe_params :ctz=>String, :futureevents => :boolean, :orderby => ["lastmodified", "starttime"]
      describe_params :recurrance_expansion_start=>:date_or_time, :recurrance_expansion_end=>:date_or_time
      describe_params :singleevents => :boolean, :showhidden => :boolean, :sortorder => ["ascending", "descending"]
      describe_params :start_min=>:date_or_time, :start_max=>:date_or_time
      
      def initialize
        self[:singleevents] = true
        self[:sortorder] = "ascending"
        self[:orderby] = "starttime"
      end
      
      def validate!
        self[:recurrance_expansion_start] = self[:start_min] if self[:start_min]
        self[:recurrance_expansion_end] = self[:start_max] if self[:start_max]
        super
      end
    end
  end
end


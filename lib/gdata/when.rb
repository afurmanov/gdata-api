module GData
  class When < Atom::Base
    elements "@valueString?", "@startTime"=>DateTime, "@endTime?"=>DateTime
    def self.node_name; "gd:when"; end
  end
end


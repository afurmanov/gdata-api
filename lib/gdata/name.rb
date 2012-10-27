module GData
  class Name < Atom::Base
    elements "gd:givenName?", "gd:additionalName?", "gd:familyName?", "gd:namePrefix?", "gd:nameSuffix?", "gd:fullName?"
    def self.node_name; "gd:name"; end
  end
end


module GData
  class PhoneNumber < Atom::Base
    elements "@label?", "@rel?", "@uri?", "@primary?", "text()"
    def self.node_name; "gd:phoneNumber"; end
  end
end
  

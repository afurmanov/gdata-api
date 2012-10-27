module GData
  class Email < Atom::Base
    elements "@address", "@displayName", "@label?", "@rel?", "@primary?"
  end
end


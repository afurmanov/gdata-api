module GData
  module Atom
    class Link < Base
      elements '@href', '@rel?'
    end
  end
end

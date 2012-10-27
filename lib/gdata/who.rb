module GData
  class Who < Atom::Base
    elements "@email?", "@rel?", "@valueString?"
    elements "gd:attendeeStatus?", "gd:attendeeType?", "gd:entryLink?"
  end
end

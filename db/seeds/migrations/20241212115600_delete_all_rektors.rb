# frozen_string_literal: true

# Du skal sannsynlig aldri kontakte rektor direkte, og informasjonen er utdatert da vi ikke lenger får den fra NSR.
SpaceContact.where("title LIKE 'Rektor%'").destroy_all

# frozen_string_literal: true

class AggregatedFacilityReview < ApplicationRecord
  enum experience: { unknown: 0, impossible: 1, unlikely: 2, maybe: 3, likely: 4 }

  belongs_to :facility
  belongs_to :space

  def tooltip
    case experience
    when 'unknown'
      'Usikkert. Ingen har spurt!'
    when 'impossible'
      'Umulig. De har ikke.'
    when 'unlikely'
      'Usannsynlig. Ingen eller få har fått lov'
    when 'maybe'
      'Kanskje! Ikke alle får lov'
    when 'likely'
      'Sannsynlig! Andre har fått lov!'
    else
      'Vet ikke'
    end
  end
end

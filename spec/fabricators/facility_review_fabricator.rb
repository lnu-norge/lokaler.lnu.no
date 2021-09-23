# frozen_string_literal: true

Fabricator(:facility_review) do
  facility
  space
  user
  review
  experience 'allowed'
end

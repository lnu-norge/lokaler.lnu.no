# frozen_string_literal: true

def demo_reviews_for_space(space) # rubocop:disable Metrics/MethodLength
  ### Add some reviews

  positive_review_comment = 'Proff skole som har lyst til å ta oss i mot.

God kommunikasjon.

Fikk ikke bruke kjøkkenet (pga allergier), men fikk lov til å bruke spisesal og ta med medbrakt.'

  user = User.create(
    first_name: "Kari",
    last_name: "Nordmann",
    email: "test@test.no",
  )

  Review.create(
    user:,
    comment: positive_review_comment,
    star_rating: 4,
    space:
  )
  FacilityReview.create(
    facility: Facility.first,
    space:,
    user:,
    experience: :was_allowed
  )
  FacilityReview.create(
    facility: Facility.all[6],
    space:,
    user:,
    experience: :was_allowed
  )
  FacilityReview.create(
    facility: Facility.all[2],
    space:,
    user:,
    experience: :was_allowed
  )
  FacilityReview.create(
    facility: Facility.all[5],
    space:,
    user:,
    experience: :was_not_allowed
  )

  negative_review_comment = "De sa de ikke kunne tillate overnatting fordi bygge tikke tillot det! Bare tull!

Det er diskriminering av oss!

Greit nok at vi rota litt sist vi var der, men det går nå raskt å vaske!"

  negative_user = User.create(
    first_name: "Judas",
    last_name: "Beelzebub",
    email: "test2@test.no",
  )

  Review.create(
    user: negative_user,
    comment: negative_review_comment,
    star_rating: nil,
    space:
  )
  FacilityReview.create(
    facility: Facility.first,
    space:,
    user: negative_user,
    experience: :was_not_allowed
  )
end

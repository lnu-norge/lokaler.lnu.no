# frozen_string_literal: true

def demo_reviews_for_space(space) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  ### Add some reviews

  positive_review_comment = 'Proff skole som har lyst til å ta oss i mot.

God kommunikasjon.

Fikk ikke bruke kjøkkenet (pga allergier), men fikk lov til å bruke spisesal og ta med medbrakt.'

  user = User.create(
    first_name: "Kari",
    last_name: "Nordmann",
    email: "test@test.no",
    password: "password",
    password_confirmation: "password"
  )

  positive_review = Review.create(
    title: "Ryddig og hyggelig skole!",
    user: user,
    price: 5400,
    comment: positive_review_comment,
    star_rating: 4,
    type_of_contact: :been_there,
    space: space
  )
  FacilityReview.create(
    facility: Facility.first,
    space: space,
    review: positive_review,
    user: user,
    experience: :was_allowed
  )
  FacilityReview.create(
    facility: Facility.all[6],
    space: space,
    review: positive_review,
    user: user,
    experience: :was_allowed
  )
  FacilityReview.create(
    facility: Facility.all[2],
    space: space,
    review: positive_review,
    user: user,
    experience: :was_allowed
  )
  FacilityReview.create(
    facility: Facility.all[5],
    space: space,
    review: positive_review,
    user: user,
    experience: :was_not_allowed
  )

  negative_review_comment = "De sa de ikke kunne tillate overnatting fordi bygge tikke tillot det! Bare tull!

Det er diskriminering av oss!

Greit nok at vi rota litt sist vi var der, men det går nå raskt å vaske!"

  negative_user = User.create(
    first_name: "Judas",
    last_name: "Beelzebub",
    email: "test2@test.no",
    password: "password",
    password_confirmation: "password"
  )

  negative_review = Review.create(
    title: "Ville ikke la oss overnatte!",
    user: negative_user,
    comment: negative_review_comment,
    star_rating: nil,
    space: space,
    type_of_contact: :not_allowed_to_use
  )
  FacilityReview.create(
    facility: Facility.first,
    space: space,
    review: negative_review,
    user: negative_user,
    experience: :was_not_allowed
  )
end

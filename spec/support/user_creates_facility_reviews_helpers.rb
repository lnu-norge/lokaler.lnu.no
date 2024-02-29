# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength # This is a test helper, it's fine
module UserCreatesFacilityReviewsHelpers
  def expect_to_only_change_facility_review_description(
    space:,
    facility:,
    description_to_add: ""
  )

    expected_previous_experience =
      space.reload
           .relevant_space_facilities
           .find_by(facility:)
           .experience

    expect_to_add_facility_review(
      space:,
      facility:,
      description_to_add:,
      count_that_already_have_the_new_experience: 1,
      count_that_changes_to_new_experience: 0,
      expected_previous_experience:
    )
  end

  # rubocop:disable Metrics/ParameterLists # This is a test helper, it's fine
  def expect_to_add_facility_review(
    space:,
    facility:,
    description_to_add: "",
    count_that_already_have_the_new_experience: 0,
    expected_previous_experience: "unknown",
    expected_new_experience: "likely",
    count_that_changes_to_new_experience: 1
  )

    expect_changes_around_reviewing_facility(
      facility:,
      space:,
      expected_previous_experience:,
      expected_new_experience:,
      expected_new_description: description_to_add,
      count_that_already_have_the_new_experience:,
      count_that_changes_to_new_experience:
    ) do
      click_to_create_new_facility_review(
        facility:,
        description_to_add:
      )
    end
  end
  # rubocop:enable Metrics/ParameterLists

  def expect_to_add_multiple_facility_reviews(
    space:,
    facilities_to_review: []
  )
    expect_changes_around_reviewing_facility(
      facility: facilities_to_review,
      space:,
      count_that_changes_to_new_experience: facilities_to_review.count
    ) do
      click_to_create_multiple_facility_reviews(
        facilities_to_review:
      )
    end
  end

  def click_to_create_new_facility_review(facility:,
                                          description_to_add: "")
    open_form_modal

    enter_data_about_facility(facility:, description_to_add:)

    save_form_modal
  end

  def click_to_create_multiple_facility_reviews(facilities_to_review: [])
    open_form_modal

    facilities_to_review.each do |facility|
      enter_data_about_facility(facility:)
    end

    save_form_modal
  end

  def open_form_modal
    # Click the edit button
    find("button[aria-label='Rediger fasiliteter']").click
  end

  def save_form_modal
    click_on(I18n.t("facility_reviews.save"))

    # Wait for the save to go through
    expect(page).to have_text(I18n.t("reviews.added_review"))
  end

  def enter_data_about_facility(facility:, description_to_add: "")
    fieldset = first("fieldset", text: facility.title)
    within(fieldset) do
      click_on("Rediger")
      choose(I18n.t("reviews.form.facility_experience_particular_tense.was_allowed"), allow_label_click: true)

      # Add a description
      fill_in(I18n.t("simple_form.labels.space_facility.description"), with: description_to_add)
    end
  end

  # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength, Metrics/AbcSize # This is a test helper, it's fine
  def expect_changes_around_reviewing_facility(
    facility:,
    space:,
    count_that_already_have_the_new_experience: 0,
    count_that_changes_to_new_experience: 1,
    count_of_visible_facilities: space.relevant_space_facilities.count,
    expected_previous_experience: "unknown",
    expected_new_experience: "likely",
    expected_new_description: ""
  )

    count_should_have_new_experience =
      count_that_already_have_the_new_experience + count_that_changes_to_new_experience

    count_should_have_unknown_experience_at_start =
      count_of_visible_facilities - count_that_already_have_the_new_experience

    count_should_have_unknown_experience =
      count_of_visible_facilities - count_should_have_new_experience

    # CSS selectors for reviewed and non reviewed facilities
    no_reviews_selector = "li[title='#{I18n.t('tooltips.facility_aggregated_experience.unknown')}']"
    reviewed_selector = "li[title='#{I18n.t("tooltips.facility_aggregated_experience.#{expected_new_experience}")}']"

    relevant_space_facilities = space.relevant_space_facilities
    space_facilities_matching_facility = relevant_space_facilities.where(facility:)

    # Expect that we have more than one facility visible:
    expect(count_of_visible_facilities).to be > 1

    # Expect that none of those facilities to show as reviewed so far in the model:
    expect(
      relevant_space_facilities.where(experience: expected_new_experience).count
    ).to eq(count_that_already_have_the_new_experience)

    expect(
      space_facilities_matching_facility.reload.all? do |space_facility|
        space_facility.experience == expected_previous_experience
      end
    ).to be(true)

    # And are not reviewed in the rendered HTML either:
    expect(page).to have_selector(
      no_reviews_selector,
      count: count_should_have_unknown_experience_at_start
    )

    # Do the actions
    yield

    # Check that the reviewed facility changed in the model:
    expect(
      space_facilities_matching_facility.reload.all? do |space_facility|
        space_facility.experience == expected_new_experience
      end
    ).to be(true)

    expect(
      relevant_space_facilities.where(experience: expected_new_experience).count
    ).to eq(count_should_have_new_experience)
    # as well as in the rendered HTML:
    expect(page).to have_selector(
      reviewed_selector,
      count: count_should_have_new_experience
    )

    # Check that no other facilities changed in model
    expect(
      relevant_space_facilities.where(experience: "unknown").count
    ).to eq(count_should_have_unknown_experience)
    # or in the rendered HTML:
    expect(page).to have_selector(
      no_reviews_selector,
      count: count_should_have_unknown_experience
    )

    return if expected_new_description.blank?

    # Check that the description changed in the model

    expect(
      space_facilities_matching_facility.all? do |space_facility|
        space_facility.description == expected_new_description
      end
    ).to be(true)

    # and in the rendered HTML:
    expect(page).to have_text(expected_new_description)
  end
  # rubocop:enable Metrics/ParameterLists, Metrics/MethodLength, Metrics/AbcSize
end
# rubocop:enable Metrics/ModuleLength

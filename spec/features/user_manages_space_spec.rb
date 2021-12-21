# frozen_string_literal: true

require "rails_helper"

describe "User manages homepage", js: true do
  let!(:space_type) { Fabricate(:space_type) }
  let!(:space_group) { Fabricate(:space_group) }
  let!(:space) { Fabricate(:space, address: "Ulefossvegen 32", post_number: 3730, post_address: "Skien") }

  before do
    create_user!
  end

  it "user is alerted that a similar space already exists, but can still create a new space as a duplicate" do
    login_and_logout_with_warden do
      visit root_path
      click_link I18n.t("menu.new_space")

      expect(page).to have_text(I18n.t("space_listing.new_space"))

      fill_in "space_title", with: space.title
      fill_in "space_address", with: space.address
      fill_in "space_post_number", with: space.post_number
      fill_in "space_post_address", with: space.post_address

      expect(page).to have_text(I18n.t("space_create.any_of_these.one"))

      click_button I18n.t("space_create.none_are_duplicates.one")

      tom_select("select#space_space_type_id", option_id: space_type.id)
      tom_select("select#space_space_group_title", option_id: space_group.title)
      click_button I18n.t("helpers.submit.create", model: Space.model_name.human)
      expect(page).to have_text(space.title)
    end
  end

  it "user edits space title" do
    login_and_logout_with_warden do
      visit space_path(id: space.id)
      click_link "edit_basics"

      fill_in "space_title", with: "New Space Title"

      click_button "Lagre"
      expect(page).to have_text("New Space Title")
    end
  end

  it "user edits space basics unsuccessfully" do
    login_and_logout_with_warden do
      visit space_path(id: space.id)
      click_link "edit_basics"

      fill_in "space_title", with: ""
      fill_in "space_url", with: "asd"
      fill_in "space_address", with: ""
      fill_in "space_post_number", with: ""
      fill_in "space_post_address", with: ""

      click_button "Lagre"
      expect(page).to have_text("Title #{I18n.t('errors.messages.blank')}")
      expect(page).to have_text("Nettside #{I18n.t('activerecord.errors.models.space.attributes.url.url')}")
      expect(page).to have_text("Adresse #{I18n.t('errors.messages.blank')}")
      expect(page).to have_text("Postnummer #{I18n.t('errors.messages.blank')}")
      expect(page).to have_text("Poststed #{I18n.t('errors.messages.blank')}")
    end
  end

  it "user adds new space contact" do
    login_and_logout_with_warden do
      visit space_path(id: space.id)
      click_button "space_contacts_new"

      fill_in "space_contact_title", with: "Space Contact Title"
      fill_in "space_contact_telephone", with: "48484848"

      click_button "Lagre"
      expect(page).to have_text("Space Contact Title")
    end
  end

  it "user adds new space contact unsuccessfully" do
    login_and_logout_with_warden do
      visit space_path(id: space.id)
      click_button "space_contacts_new"

      fill_in "space_contact_title", with: "Space Contact Title"

      click_button "Lagre"
      expect(page).to have_text("Telefon #{I18n.t('space_contact.at_least_one_error_message.telephone')}")
      expect(page).to have_text("E-post #{I18n.t('space_contact.at_least_one_error_message.email')}")
      expect(page).to have_text("Nettside #{I18n.t('space_contact.at_least_one_error_message.url')}")
      expect(page).to have_text("Beskrivelse #{I18n.t('space_contact.at_least_one_error_message.description')}")
    end
  end

  it "user deletes space_contact" do
    login_and_logout_with_warden do
      space_contact = Fabricate(:space_contact, space: space)

      visit space_path(id: space.id)
      click_link "edit_space_contact_#{space_contact.id}"

      page.accept_alert I18n.t("space_contacts.delete_confirmation") do
        click_link I18n.t("space_contacts.delete")
      end

      expect(page).not_to have_text(space_contact.title)
    end
  end
end

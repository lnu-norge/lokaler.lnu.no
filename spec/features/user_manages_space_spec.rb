# frozen_string_literal: true

require "rails_helper"

describe Space, js: true do
  let!(:space_type) { Fabricate(:space_type) }
  let!(:space_group) { Fabricate(:space_group) }
  let!(:space) { Fabricate(:space, address: "Ulefossvegen 32", post_number: 3730, post_address: "Skien") }

  before do
    create_user!
  end

  it "user adds new space successfully" do
    login_and_logout_with_warden do
      visit root_path
      click_link "Nytt lokale"

      expect(page).to have_text("Legg til nytt lokale")

      fill_in "space_title", with: "Space title!"
      tom_select("select#space_space_type_id", option_id: space_type.id)

      fill_in "space_address", with: "Ulefossvegen 32"
      fill_in "space_post_number", with: "3730"
      fill_in "space_post_address", with: "Skien"

      tom_select("select#space_space_group_title", option_id: space_group.title)

      click_button "Lag Lokale"
      expect(page).to have_text("Space title!")
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
      expect(page).to have_text("Title kan ikke være blank")
      expect(page).to have_text("Nettside er ikke korrekt")
      expect(page).to have_text("Adresse kan ikke være blank")
      expect(page).to have_text("Postnummer kan ikke være blank")
      expect(page).to have_text("Poststed kan ikke være blank")
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
      expect(page).to have_text("Telefon må velges, eventuelt legg inn e-post, nettside eller beskrivelse")
      expect(page).to have_text("E-post må velges, eventuelt legg inn telefon, nettside eller beskrivelse")
      expect(page).to have_text("Nettside må velges, eventuelt legg inn telefon, e-post eller beskrivelse")
      expect(page).to have_text("Beskrivelse må velges, eventuelt legg inn telefon, e-post eller nettside")
    end
  end

  it "user adds new space contact with invalid website" do
    login_and_logout_with_warden do
      visit space_path(id: space.id)
      click_button "space_contacts_new"

      fill_in "space_contact_title", with: "Space Contact Title"
      fill_in "space_contact_url", with: "asd"

      click_button "Lagre"
      expect(page).to have_text("Nettside er ikke korrekt")
    end
  end

  it "user adds new space contact with invalid phone" do
    login_and_logout_with_warden do
      visit space_path(id: space.id)
      click_button "space_contacts_new"

      fill_in "space_contact_title", with: "Space Contact Title"
      fill_in "space_contact_telephone", with: "48"

      click_button "Lagre"
      expect(page).to have_text("Telefon er ugyldig")
    end
  end

  it "user deletes space_contact" do
    login_and_logout_with_warden do
      space_contact = Fabricate(:space_contact, space: space)

      visit space_path(id: space.id)
      click_link "edit_space_contact_#{space_contact.id}"

      page.accept_alert "Er du sikker på at du vil slette?" do
        click_link "Slett kontakt"
      end

      expect(page).not_to have_text(space_contact.title)
    end
  end
end

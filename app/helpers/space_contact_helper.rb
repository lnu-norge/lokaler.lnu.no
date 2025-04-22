# frozen_string_literal: true

module SpaceContactHelper
  def dom_id_form_for_new_space_contact_for(space)
    "new_space_contact_for_#{space.id}"
  end

  def dom_id_button_for_new_space_contact_for(space)
    "new_space_contact_button_for_#{space.id}"
  end

  def dom_id_new_space_contact_modal(space)
    "new_space_contact_modal_for_#{space.id}"
  end

  def dom_id_for_space_contacts_stream(space)
    "space_contacts_for_space_#{space.id}"
  end

  def format_phone_number(number)
    number.gsub(/\s/, "").split(/(\+?\d{2})/).join(" ")
  end
end

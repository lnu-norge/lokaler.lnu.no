# frozen_string_literal: true

class SpaceContactsController < BaseControllers::AuthenticateController
  include SpaceContactHelper
  before_action :set_space_contact, except: [:create]

  def create
    @space_contact = SpaceContact.new(space_contact_params)
    return successful_save if @space_contact.save

    error_handling
  end

  def update
    return if @space_contact.update(space_contact_params)

    render turbo_stream: turbo_stream.replace(
      @space_contact,
      partial: "space_contacts/edit",
      locals: { space_contact: @space_contact }
    )
  end

  def destroy
    return if @space_contact.destroy

    flash.now[:error] = t("space_contacts.contact_not_deleted")
  end

  private

  def successful_save
    # When saved, load the new button again
    render turbo_stream: turbo_stream.replace(
      dom_id_for_button,
      partial: "space_contacts/new_button",
      locals: {
        space_contact: @space_contact
      }
    )
  end

  def error_handling
    # Error handling, show the errors:
    render turbo_stream: turbo_stream.replace(
      dom_id_for_form,
      partial: "space_contacts/new",
      locals: {
        space_contact: @space_contact
      }
    )
  end

  def set_space_contact
    @space_contact = SpaceContact.find(params[:id])
  end

  def dom_id_for_button
    dom_id_button_for_new_space_contact_for(@space_contact.space || @space_contact.space_group)
  end

  def dom_id_for_form
    dom_id_form_for_new_space_contact_for(@space_contact.space || @space_contact.space_group)
  end

  def space_contact_params
    params.require(:space_contact).permit(
      :title,
      :telephone,
      :telephone_opening_hours,
      :email,
      :url,
      :description,
      :priority,
      :space_id,
      :space_group_id
    )
  end
end

# frozen_string_literal: true

class SpaceContactsController < BaseControllers::AuthenticateController # rubocop:disable Metrics/ClassLength
  include SpaceContactHelper
  before_action :set_space_contact, except: [:create]

  def create
    @space_contact = SpaceContact.new(space_contact_params)
    if @space_contact.save
      # Broadcast the new contact to all subscribers
      Turbo::StreamsChannel.broadcast_prepend_later_to(
        dom_id_for_relevant_space_contacts_stream,
        target: dom_id_for_relevant_space_contacts_stream,
        partial: "space_contacts/space_contact",
        locals: { space_contact: @space_contact }
      )
      return successful_save
    end

    error_handling
  end

  def update
    if @space_contact.update(space_contact_params)
      # Broadcast the updated contact to all subscribers
      Turbo::StreamsChannel.broadcast_replace_later_to(
        dom_id_for_relevant_space_contacts_stream,
        target: @space_contact,
        partial: "space_contacts/space_contact",
        locals: { space_contact: @space_contact }
      )
      return successful_update
    end

    render turbo_stream: turbo_stream.replace(
      @space_contact,
      partial: "space_contacts/edit",
      locals: { space_contact: @space_contact }
    )
  end

  def destroy
    contact_id = @space_contact.id
    stream_id = dom_id_for_relevant_space_contacts_stream
    if @space_contact.destroy
      # Broadcast the deletion to all subscribers
      Turbo::StreamsChannel.broadcast_remove_to(
        stream_id,
        target: "space_contact_#{contact_id}"
      )
      return successful_delete
    end

    flash.now[:error] = t("space_contacts.contact_not_deleted")
  end

  private

  def dom_id_for_relevant_space_contacts_stream
    dom_id_for_space_contacts_stream(@space_contact.space || @space_contact.space_group)
  end

  def turbo_update_flash(flash_message:, flash_type: :notice)
    flash.now[flash_type] = flash_message
    turbo_stream.update(
      :flash,
      partial: "shared/flash"
    )
  end

  def successful_update
    flash_message = t("space_contacts.contact_updated")
    render turbo_stream: [
      turbo_update_flash(flash_message:)
    ]
  end

  def successful_delete
    flash_message = t("space_contacts.contact_deleted")
    render turbo_stream: [
      turbo_update_flash(flash_message:)
    ]
  end

  def successful_save
    # Add flash message, update contacts list, and close the modal
    flash_message = t("space_contacts.contact_created")
    render turbo_stream: [
      turbo_update_flash(flash_message:),
      turbo_stream.update("global_modal", "")
    ]
  end

  def error_handling
    # Error handling, show the errors:
    render turbo_stream: turbo_stream.replace(
      dom_id_for_form,
      partial: "space_contacts/new",
      locals: {
        space: @space_contact.space,
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

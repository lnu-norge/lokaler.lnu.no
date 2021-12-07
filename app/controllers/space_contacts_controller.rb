# frozen_string_literal: true

class SpaceContactsController < AuthenticateController
  before_action :set_space_contact, except: [:create]

  def create
    @space_contact = SpaceContact.new(space_contact_params)

    saved = @space_contact.save
    @space_contact = saved ? SpaceContact.new(space: @space_contact.space) : @space_contact

    # When saved, load the new button again
    if saved
      @space = @space_contact.space
      render turbo_stream: turbo_stream.replace(
        "new_space_contact_button",
        partial: "space_contacts/new_button"
      )
    else
      # Error handling, show the errors:
      render turbo_stream: turbo_stream.replace(
        "new_space_contact_form",
        partial: "space_contacts/new",
        locals: { space_contact: @space_contact }
      )
    end
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

  def set_space_contact
    @space_contact = SpaceContact.find(params[:id])
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

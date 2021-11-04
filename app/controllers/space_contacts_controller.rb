# frozen_string_literal: true

class SpaceContactsController < AuthenticateController
  before_action :set_space_contact, except: [:create]

  def create
    @space_contact = SpaceContact.create!(space_contact_params)

    return if @space_contact.save

    render turbo_stream: turbo_stream.replace(
      @space_contact,
      partial: 'space_contacts/form',
      locals: { space_contact: @space_contact }
    )
  end

  def update
    return if @space_contact.update(space_contact_params)

    render :edit, status: :unprocessable_entity
  end

  def destroy
    return if @space_contact.destroy

    flash.now[:error] = t('space_contacts.contact_not_deleted')
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
      :space_owner_id
    )
  end
end

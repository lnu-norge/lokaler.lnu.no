# frozen_string_literal: true

class SpaceContactsController < AuthenticateController
  before_action :set_space_contact, except: [:create]

  def create
    @space_contact = SpaceContact.create!(space_contact_params)

    if @space_contact.save
      redirect_to space_path(@space_contact.space_id), notice: t('space_contacts.contact_created')
    else
      render turbo_stream: turbo_stream.replace(
        @space_contact,
        partial: 'space_contacts/form',
        locals: { space_contact: @space_contact }
      )
    end
  end

  def update
    if @space_contact.update(space_contact_params)
      redirect_to space_path(@space_contact.space_id), notice: t('space_contacts.contact_updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @space_contact.destroy
      redirect_to space_path(@space_contact.space_id), notice: t('space_contacts.contact_deleted')
    else
      flash.now[:error] = t('space_contacts.contact_not_deleted')
    end
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

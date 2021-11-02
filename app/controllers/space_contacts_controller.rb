# frozen_string_literal: true

class SpaceContactsController < AuthenticateController
  # def index
  #   @space_contacts = SpaceContact.all
  #   @space_contact = SpaceContact.new
  # end

  # def show
  #   @space_contact = SpaceContact.find(params[:id])
  # end

  def create
    SpaceContact.create!(space_contact_params)
    redirect_to space_path(space_contact_params[:space_id])
  end

  def edit
    @space_contact = SpaceContact.find(params[:id])
  end

  def update
    @space_contact = SpaceContact.find(params[:id])

    if @space_contact.update(space_contact_params)
      redirect_to space_path(space_contact_params[:space_id])
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

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

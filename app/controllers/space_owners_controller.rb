# frozen_string_literal: true

class SpaceOwnersController < ApplicationController
  def index
    @space_owners = SpaceOwner.all
    @space_owner = SpaceOwner.new
  end

  def show
    @space_owner = SpaceOwner.find(params[:id])
  end

  def create
    @space_owner = SpaceOwner.create!(space_owner_params)

    redirect_to space_owners_path
  end

  def edit
    @space_owner = SpaceOwner.find(params[:id])
  end

  def update
    @space_owner = SpaceOwner.find(params[:id])

    if @space_owner.update(space_owner_params)
      redirect_to space_owners_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def space_owner_params
    params.require(:space_owner).permit(
      :orgnr,
      :title,
      :how_to_book,
      :about,
      :terms,
      :pricing,
      :who_can_use
    )
  end
end

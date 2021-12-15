# frozen_string_literal: true

class SpaceGroupsController < AuthenticateController
  def index
    @space_groups = SpaceGroup.all
    @space_group = SpaceGroup.new
  end

  def show
    @space_group = SpaceGroup.find(params[:id])
  end

  def create
    @space_group = SpaceGroup.create!(space_group_params)

    redirect_to space_groups_path
  end

  def edit
    @space_group = SpaceGroup.find(params[:id])
  end

  def update
    @space_group = SpaceGroup.find(params[:id])

    if @space_group.update(space_group_params)
      redirect_to space_groups_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def space_group_params
    params.require(:space_group).permit(
      :title,
      :how_to_book,
      :about,
      :terms,
      :pricing,
      :who_can_use
    )
  end
end

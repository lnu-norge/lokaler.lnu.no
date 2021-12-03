# frozen_string_literal: true

module Admin
  class SpaceTypesController < Admin::AdminController
    before_action :set_space_type, except: [:index, :new, :create]

    def index
      @space_types = SpaceType.all.order(:type_name)
    end

    def show; end

    def new
      @space_type = SpaceType.new
    end

    def create
      @space_type = SpaceType.new(space_type_params)
      if @space_type.save
        redirect_to admin_space_types_path, notice: "Space type was successfully created."
      else
        render :new
      end
    end

    def edit; end

    def update
      if @space_type.update(space_type_params)
        redirect_to admin_space_types_path, notice: "Space type was successfully updated."
      else
        render :edit
      end
    end

    def destroy
      @space_type.destroy
      redirect_to admin_space_types_path, notice: "Space type was successfully destroyed."
    end

    private

    def set_space_type
      @space_type = SpaceType.find(params[:id])
    end

    def space_type_params
      params.require(:space_type).permit(:type_name)
    end
  end
end

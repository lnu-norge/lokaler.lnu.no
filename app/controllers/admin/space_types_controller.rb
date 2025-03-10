# frozen_string_literal: true

module Admin
  class SpaceTypesController < BaseControllers::AuthenticateAsAdminController
    before_action :set_space_type, except: [:index, :new, :create]

    def index
      @space_types = SpaceType.order(:type_name)
    end

    def show; end

    def new
      @space_type = SpaceType.new
    end

    def edit; end

    def create
      @space_type = SpaceType.new(space_type_params)
      if @space_type.save
        redirect_to admin_space_types_path, notice: t("space_types.created")
      else
        render :new
      end
    end

    def update
      if @space_type.update(space_type_params)
        redirect_to admin_space_types_path, notice: t("space_types.updated")
      else
        render :edit
      end
    end

    def destroy
      return redirect_to admin_space_types_path, notice: t("space_types.deleted") if @space_type.destroy

      flash.now[:error] = t("space_contacts.contact_not_deleted")
    end

    private

    def set_space_type
      @space_type = SpaceType.find(params[:id])
    end

    def space_type_params
      params.require(:space_type).permit(:type_name, facility_ids: [])
    end
  end
end

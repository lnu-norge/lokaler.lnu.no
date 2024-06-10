# frozen_string_literal: true

class PersonalSpaceListsController < BaseControllers::AuthenticateController
  include AccessToPersonalSpaceListVerifiable
  before_action :set_personal_space_list, only: %i[show edit update destroy]
  before_action :new_personal_space_list, only: [:create]
  before_action :add_spaces_to_list, only: [:create, :update]
  before_action :verify_that_user_has_access_to_personal_space_list

  after_action :activate_or_deactivate_list_based_on_params, only: [:create, :update]

  def index
    @active_personal_space_list = PersonalSpaceList
                                  .joins(:active_personal_space_list)
                                  .find_by(
                                    user: current_user,
                                    active_personal_space_list: { user: current_user }
                                  )
    @inactive_personal_space_lists = PersonalSpaceList
                                     .where(user: current_user)
                                     .where.not(id: @active_personal_space_list&.id)
  end

  def show
    @personal_data_on_space_in_lists = @personal_space_list.personal_data_on_space_in_lists.order(id: :desc)
  end

  def new
    @personal_space_list = PersonalSpaceList.new(user: current_user)
  end

  # GET /personal_space_lists/1/edit
  def edit; end

  def create
    respond_to do |format|
      if @personal_space_list.save
        format.html do
          redirect_to personal_space_lists_url, notice: t("personal_space_lists.list_created")
        end
        format.json { render :show, status: :created, location: @personal_space_list }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @personal_space_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /personal_space_lists/1 or /personal_space_lists/1.json
  def update
    respond_to do |format|
      if @personal_space_list.update(personal_space_list_params)
        format.html do
          redirect_to personal_space_list_url(@personal_space_list), notice: t("personal_space_lists.list_updated")
        end
        format.json { render :show, status: :ok, location: @personal_space_list }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @personal_space_list.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @personal_space_list.destroy!

    respond_to do |format|
      format.html { redirect_to personal_space_lists_url, notice: t("personal_space_lists.list_deleted") }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_personal_space_list
    return new_personal_space_list if params[:id] == "new"

    @personal_space_list = PersonalSpaceList.find(params[:id])
    @active_personal_space_list = @personal_space_list
  end

  def new_personal_space_list
    @personal_space_list = PersonalSpaceList.new(
      personal_space_list_params
    )
  end

  def add_spaces_to_list
    return unless params[:personal_space_list][:spaces_ids]

    space_ids = params[:personal_space_list][:spaces_ids].reject(&:empty?).map(&:to_i).uniq
    spaces_from_params = Space.find(space_ids)
    @personal_space_list.update(spaces: spaces_from_params, updated_at: Time.zone.now)
  end

  # Only allow a list of trusted parameters through.
  def personal_space_list_params
    allowed_params = params.require(:personal_space_list).permit(:user_id, { spaces_ids: [] }, :title, :active)

    @active_param = allowed_params[:active].to_s
    allowed_params.delete(:active) # Not part of the model, but used by the controller
    allowed_params.delete(:spaces_ids) # Not part of the model, but used by the controller

    allowed_params[:user_id] = current_user.id if allowed_params[:user_id].blank?

    allowed_params
  end

  def activate_or_deactivate_list_based_on_params
    return if @active_param.blank?

    return @personal_space_list.activate if @active_param == "1"

    @personal_space_list.deactivate
  end
end

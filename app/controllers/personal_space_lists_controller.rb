# frozen_string_literal: true

class PersonalSpaceListsController < BaseControllers::AuthenticateController
  before_action :set_personal_space_list, only: %i[show edit update destroy]
  before_action :verify_that_user_has_access
  before_action :add_spaces_to_list, only: [:create, :update]

  def index
    @personal_space_lists = PersonalSpaceList.where(user: current_user)
  end

  def show; end

  def new
    @personal_space_list = PersonalSpaceList.new(user: current_user)
  end

  # GET /personal_space_lists/1/edit
  def edit; end

  def create
    @personal_space_list = PersonalSpaceList.new(
      personal_space_list_params
    )

    respond_to do |format|
      if @personal_space_list.save
        format.html do
          redirect_to personal_space_list_url(@personal_space_list), notice: t("personal_space_lists.list_created")
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
    @personal_space_list = PersonalSpaceList.find(params[:id])
  end

  def add_spaces_to_list
    return unless params[:personal_space_list][:spaces_ids]

    space_ids = params[:personal_space_list][:spaces_ids].reject(&:empty?).map(&:to_i).uniq
    spaces_from_params = Space.find(space_ids)
    @personal_space_list.spaces = spaces_from_params
  end

  # Only allow a list of trusted parameters through.
  def personal_space_list_params
    allowed_params = params.require(:personal_space_list).permit(:user_id, :spaces_ids, :title)
    allowed_params[:user_id] = current_user.id

    allowed_params
  end

  def verify_that_user_has_access
    return unless params[:user_id]
    return if params[:user_id] == current_user.id
    return if current_user.admin?

    redirect_to personal_space_lists_url, alert: t("personal_space_lists.no_access")
  end
end

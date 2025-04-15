# frozen_string_literal: true

module Admin
  class SyncStatusesController < BaseControllers::AuthenticateAsAdminController
    before_action :set_sync_status, only: %i[show edit update destroy]

    # GET /sync_statuses or /sync_statuses.json
    def index
      @sync_statuses = SyncStatus.all
    end

    # GET /sync_statuses/1 or /sync_statuses/1.json
    def show; end

    # GET /sync_statuses/new
    def new
      @sync_status = SyncStatus.new
    end

    # GET /sync_statuses/1/edit
    def edit; end

    # POST /sync_statuses or /sync_statuses.json
    def create
      @sync_status = SyncStatus.new(sync_status_params)

      respond_to do |format|
        if @sync_status.save
          format.html { redirect_to @sync_status, notice: t("admin.sync_statuses.created") }
          format.json { render :show, status: :created, location: @sync_status }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @sync_status.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /sync_statuses/1 or /sync_statuses/1.json
    def update
      respond_to do |format|
        if @sync_status.update(sync_status_params)
          format.html { redirect_to @sync_status, notice: t("admin.sync_statuses.updated") }
          format.json { render :show, status: :ok, location: @sync_status }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @sync_status.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /sync_statuses/1 or /sync_statuses/1.json
    def destroy
      @sync_status.destroy!

      respond_to do |format|
        format.html do
          redirect_to admin_sync_statuses_path, status: :see_other, notice: t("admin.sync_statuses.destroyed")
        end
        format.json { head :no_content }
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_sync_status
      @sync_status = SyncStatus.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def sync_status_params
      params.require(:sync_status).permit(:source, :last_attempted_sync_at, :last_successful_sync, :id_from_source,
                                          :error_message, :full_error_message)
    end
  end
end

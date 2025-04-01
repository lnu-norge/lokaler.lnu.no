# frozen_string_literal: true

module Admin
  class HistoryController < BaseControllers::AuthenticateAsAdminController
    include HistoryHelper
    include Pagy::Backend

    def index
      @pagy, @versions = pagy(PaperTrail::Version.includes(:item).order(created_at: :desc), items: 10)
    end

    def show
      set_version
      set_item
      set_space
      set_user
      set_field
      set_event_name
      set_title
    end

    def revert_changes
      @old_version = PaperTrail::Version.find(params["id"])
      @old_version.reify.save!
      @new_version = @old_version.reload.next

      successful_update
    end

    private

    def successful_update
      flash_message = "Ny versjon er live"
      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = flash_message
          render turbo_stream: [
            turbo_stream.update(:flash,
                                partial: "shared/flash"),
            turbo_stream.prepend("paper_trail_versions",
                                 partial: "admin/history/version_turbo_frame",
                                 locals: { version: @new_version }),
            turbo_stream.update(dom_id_history_of(@old_version),
                                partial: "admin/history/version_turbo_frame",
                                locals: { version: @old_version })
          ]
        end
        format.html do
          flash[:notice] = flash_message
          redirect_to admin_history_path(@old_version)
        end
      end
    end

    def set_version
      @version = PaperTrail::Version.find(params[:id])
    end

    def set_item
      @item_as_changed = @version.next&.reify(dup: true) || @version.item
      @most_recent_item = @item_as_changed || @version.reify(dup: true)
    end

    def set_field
      @field = field_related_to(@most_recent_item, @version)
    end

    def set_title
      @title = "#{@event_name} #{@field} (#{@space&.title || @item_as_changed.class.name.humanize})"
    end

    def set_event_name
      event_key = @version.event.presence || "unknown"
      @event_name = t("admin.paper_trail.events.#{event_key}", default: event_key.capitalize)
    end

    def set_user
      @user = User.find(@version.whodunnit) if @version.whodunnit.present?
      @user_name = @user&.name || "ukjent bruker"
      @user_avatar_url = @user&.gravatar_url || "https://www.gravatar.com/avatar/placeholder?d=mp"
    end

    def set_space
      item = @most_recent_item

      return @space = item if item.is_a?(Space)
      return @space = item.space if defined? item.space
      return @space = item.record if item.is_a?(ActionText::RichText) && (item.record_type == "Space")

      nil
    end

    def field_related_to(item, version)
      if item.is_a?(ActionText::RichText) && (item.record_type == "Space")
        return t("activerecord.attributes.space.#{item.name}")
      end

      t("activerecord.models.#{version.item_type.downcase}", count: 1)
    end
  end
end

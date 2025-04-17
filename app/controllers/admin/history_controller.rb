# frozen_string_literal: true

module Admin
  class HistoryController < BaseControllers::AuthenticateAsAdminController # rubocop:disable Metrics/ClassLength
    include HistoryHelper
    include Pagy::Backend

    before_action :filter_params, only: :index

    def index
      versions = filtered_versions
      @pagy, @versions = pagy(versions, items: 10)
    end

    def show
      set_version
      set_missing_item_model
      set_item # Depends on set_missing_item_model
      set_missing_rich_text_model # Depends on set_item
      set_space
      set_space_group
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

    def filtered_versions # rubocop:disable Metrics/AbcSize
      versions = PaperTrail::Version.includes(:item).order(created_at: :desc)
      versions = versions.where(whodunnit: params[:user_ids]) if params[:user_ids].present?
      versions = versions.where(item_type: params[:item_type]) if params[:item_type].present?
      versions = versions.where(item_id: params[:item_id]) if params[:item_id].present?
      filter_by_space_id(versions)
    end

    def filter_by_space_id(versions)
      return versions if params[:space_id].blank?

      space_id = params[:space_id].to_i

      # Find all versions related to this space
      # This is a two-step process - first find all related items in Ruby
      # then filter using version IDs (which is faster)

      # Load all potentially related versions (after other filters applied)
      all_versions = versions.includes(:item).to_a

      # Filter for versions related to the space
      related_version_ids = all_versions.select do |version|
        version_related_to_space?(version, space_id)
      end.map(&:id)

      # Return an ActiveRecord::Relation with the filtered versions
      versions.where(id: related_version_ids)
    end

    # Check if a version is related to the specified space
    def version_related_to_space?(version, space_id)
      return true if version.item_type == "Space" && version.item_id == space_id
      return false if version.item.nil?

      related_to_space?(version.item, space_id)
    end

    # Check if an item is related to the specified space
    def related_to_space?(item, space_id) # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      return false if item.nil?

      # Same logic as in set_space
      return true if item.is_a?(Space) && item.id == space_id
      return true if defined?(item.space_id) && item.space_id == space_id
      return true if item.is_a?(ActionText::RichText) &&
                     item.record_type == "Space" &&
                     item.record_id == space_id

      false
    end

    def filter_params
      params.permit(:item_type, :item_id, :space_id, user_ids: [])
    end

    def set_version
      @version = PaperTrail::Version.find(params[:id])
    end

    def set_item
      return if @item_model_not_found

      @item_as_changed = @version.next&.reify(dup: true) || @version.item
      @most_recent_item = @item_as_changed || @version.reify(dup: true)
    end

    def set_missing_item_model
      return if Object.const_defined?(@version.item_type)

      # Handle case where model class no longer exists (e.g., renamed models)
      @item_model_not_found = true
      @item_original_model_name = @version.item_type
    end

    def set_missing_rich_text_model
      return unless @version.item_type == "ActionText::RichText"
      return if Object.const_defined?(@most_recent_item&.record_type)

      @rich_text_model_not_found = true
      @rich_text_original_model_name = @version.item.record_type
    end

    def set_field
      @field = field_related_to(@most_recent_item, @version)
    end

    def set_title
      @title = if @item_model_not_found
                 "#{@event_name} #{@field}"
               elsif @rich_text_model_not_found
                 "#{@event_name} #{@field} (#{@rich_text_original_model_name})"
               else
                 "#{@event_name} #{@field} #{"(#{@space&.title})" if @space}"
               end
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

      @space = nil
    end

    def set_space_group
      item = @most_recent_item

      return @space_group = item if item.is_a?(SpaceGroup)
      return @space_group = item.space_group if defined? item.space_group
      return @space_group = item.record if item.is_a?(ActionText::RichText) && (item.record_type == "SpaceGroup")

      @space_group = nil
    end

    def field_related_to(item, version)
      return "Ukjent modell (#{@original_model_name})" if @model_not_found
      return action_text_field_name(item) if item.is_a?(ActionText::RichText)

      t("activerecord.models.#{version.item_type.underscore}", count: 1)
    end

    def action_text_field_name(item)
      case item.record_type
      when "Space"
        t("activerecord.attributes.space.#{item.name}")
      when "SpaceGroup"
        t("activerecord.attributes.space_group.#{item.name}")
      end
    end
  end
end

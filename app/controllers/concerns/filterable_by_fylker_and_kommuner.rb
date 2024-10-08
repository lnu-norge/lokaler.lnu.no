# frozen_string_literal: true

module FilterableByFylkerAndKommuner
  extend ActiveSupport::Concern
  include SanitizeableIdList

  private

  def fylke_or_kommune_params_present?
    params[:fylker].present? || params[:kommuner].present?
  end

  def set_filtered_geo_area_ids_to_empty_arrays
    @filtered_fylke_ids, @filtered_kommune_ids, @filtered_geo_area_ids = []
  end

  def set_filtered_geo_area_ids
    return set_filtered_geo_area_ids_to_empty_arrays unless fylke_or_kommune_params_present?

    kommune_ids = sanitize_id_list(params[:kommuner])
    fylke_ids = fylke_ids_excluding_those_with_a_selected_kommune(sanitize_id_list(params[:fylker]), kommune_ids)

    @filtered_fylke_ids = fylke_ids
    @filtered_kommune_ids = kommune_ids
    @filtered_geo_area_ids = [*fylke_ids, *kommune_ids]
  end

  def fylke_ids_excluding_those_with_a_selected_kommune(unfiltered_fylke_ids, kommune_ids)
    return unfiltered_fylke_ids if kommune_ids.blank?

    fylker_for_selected_kommuner = Kommune.where(id: kommune_ids).pluck(:parent_id).uniq

    unfiltered_fylke_ids.reject do |fylke_id|
      fylker_for_selected_kommuner.include?(fylke_id)
    end
  end

  def filter_by_fylker_and_kommuner
    return @filtered_spaces unless fylke_or_kommune_params_present?

    set_filtered_geo_area_ids

    @filtered_spaces
      .filter_on_fylker_or_kommuner(
        fylke_ids: @filtered_fylke_ids,
        kommune_ids: @filtered_kommune_ids
      )
  end
end

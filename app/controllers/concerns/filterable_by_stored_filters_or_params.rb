# frozen_string_literal: true

module FilterableByStoredFiltersOrParams
  extend ActiveSupport::Concern

  private

  def any_filters_set?
    all_filter_keys.detect { |key| params[key] }
  end

  def any_filters_stored_in_session?
    session[:last_filter_params].present? &&
      all_filter_keys.any? { |key| session[:last_filter_params][key].present? }
  end

  def store_filters_in_session
    session[:last_filter_params] = {}
    all_filter_keys.each do |key|
      session[:last_filter_params][key] = params[key]
    end
  end

  def set_filters_from_session_or_params
    return params_from_search if any_filters_set?
    return params_from_session if any_filters_stored_in_session?

    set_permitted_params
  end

  def params_from_session
    all_filter_keys.each do |key|
      params[key] = session[:last_filter_params][key]
    end

    set_permitted_params
  end

  def params_from_search
    set_permitted_params
  end

  def set_permitted_params
    remove_duplicate_params
    params.permit(all_filters)
  end

  def remove_duplicate_params
    # When a facility is in multiple facility categories, they are marked as duplicates
    # using JS, by changing the name and id to start with 'duplicate_'.
    # Here we filter them out as we don't need them in the back end:
    params.delete_if { |key, _| key.to_s.start_with?("duplicate_") }
  end
end

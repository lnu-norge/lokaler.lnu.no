# frozen_string_literal: true

module FilterableByTitle
  extend ActiveSupport::Concern

  private

  def filter_by_title
    return @filtered_spaces if params[:search_for_title].blank?

    @search_by_title = params[:search_for_title]
    @filtered_spaces.filter_on_title(@search_by_title)
  end
end

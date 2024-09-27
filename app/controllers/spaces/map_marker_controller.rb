# frozen_string_literal: true

module Spaces
  class MapMarkerController < ApplicationController
    include AccessibleActivePersonalSpaceList
    before_action :access_active_personal_list, only: %i[show]

    def show
      @space = Space.find(params[:space_id])

      render json: @space.render_map_marker(options: {
                                              collapse_unless_hovered: true
                                            })
    end
  end
end

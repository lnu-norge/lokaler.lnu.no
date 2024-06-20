# frozen_string_literal: true

module TurboStreamHelper
  # Checks if the request is from turbo or not
  def turbo_request?
    turbo_frame_request_id.present?
  end
end

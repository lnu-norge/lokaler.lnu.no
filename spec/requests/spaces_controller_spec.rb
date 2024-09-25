# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Spaces", type: :request do
  let(:user) { Fabricate(:user) }

  before do
    sign_in user
  end

  describe "GET /" do
    it "loads the index page" do
      get spaces_path
      expect(response).to have_http_status(:success)
    end
  end
end

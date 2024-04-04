# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ListViews", type: :request do
  let(:user) { Fabricate(:user) }

  before do
    sign_in user
  end

  it "can load the list view path" do
    get spaces_list_view_path
    expect(response).to have_http_status(:success)
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spaces::MapVectorController, type: :request do
  let(:user) { Fabricate(:user) }
  let(:spaces) do
    Fabricate.times(
      3,
      :space,
      lat: 61.95535345226779, # Vågå-ish
      lng: 8.428730756987932 # Vågå-ish
    )
  end

  before do
    sign_in user
    spaces # Initializes spaces. Why not use "let!"?, well, because of Rubocop - of course.
  end

  it "gives 204 if no spaces in tile" do
    get space_map_vector_path(z: 21, x: 974_619, y: 1_207_236) # Middle of the ocean
    expect(response).to have_http_status(:no_content)
  end

  it "gives 200 if spaces are in tile" do
    get space_map_vector_path(z: 0, x: 0, y: 0) # Whole world
    expect(response).to have_http_status(:ok)
  end
end

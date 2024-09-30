# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spaces::MapVectorController, type: :request do
  let(:user) { Fabricate(:user) }
  let!(:spaces) do
    Fabricate.times(
      3,
      :space,
      lat: 61.95535345226779, # Vågå-ish
      lng: 8.428730756987932 # Vågå-ish
    )
  end
  let(:vector_tile_cache_key_prefix) { "#{Spaces::MapVectorController::VECTOR_TILE_CACHE_KEY_PREFIX}*" }

  before do
    sign_in user
  end

  it "gives 204 if no spaces in tile" do
    get space_map_vector_path(z: 21, x: 974_619, y: 1_207_236) # Middle of the ocean
    expect(response).to have_http_status(:no_content)
  end

  it "gives 200 if spaces are in tile" do
    get space_map_vector_path(z: 0, x: 0, y: 0) # Whole world
    expect(response).to have_http_status(:ok)
  end

  # rubocop:disable RSpec/MessageSpies
  it "caches the response" do
    expect(Rails.cache).to receive(:write).once
    get space_map_vector_path(z: 0, x: 0, y: 0) # Whole world
    expect(response).to have_http_status(:ok)
  end

  it "clears cache when a space updates the location" do
    expect(Rails.cache).to receive(:delete_matched).with(vector_tile_cache_key_prefix).once
    spaces.first.update(lat: 61.9, lng: 8.4)
    expect(spaces.first.geo_point.x.to_d).to eq(BigDecimal("8.4"))
    expect(spaces.first.geo_point.y.to_d).to eq(BigDecimal("61.9"))
  end

  it "clears cache when a space is deleted" do
    expect(Rails.cache).to receive(:delete_matched).with(vector_tile_cache_key_prefix).once
    spaces.first.destroy
  end

  it "clears cache when a space is created" do
    expect(Rails.cache).to receive(:delete_matched).with(vector_tile_cache_key_prefix).once
    Fabricate(:space)
  end
  # rubocop:enable RSpec/MessageSpies
end

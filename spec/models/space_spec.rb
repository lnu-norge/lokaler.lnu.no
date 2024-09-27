# frozen_string_literal: true

require "rails_helper"

RSpec.describe Space, type: :model do
  it "can create a space" do
    expect(Fabricate(:space)).to be_truthy
  end

  describe "filter on factilites" do
    subject(:filtered_spaces) do
      described_class.find(described_class.filter_and_order_by_facilities(facilities).pluck(:id))
    end

    let(:space_without_toilet) { Fabricate(:space) }
    let(:space_with_toilet) { Fabricate(:space) }
    let(:kitchen) { Fabricate(:facility, title: "kitchen") }
    let(:toilet) { Fabricate(:facility, title: "toilet") }
    let(:shower) { Fabricate(:facility, title: "shower") }

    before do
      Fabricate(:facility_review, space: space_without_toilet, facility: kitchen)
      Fabricate(:facility_review, space: space_without_toilet, facility: shower)
      Fabricate(:facility_review, space: space_without_toilet, facility: toilet,
                                  experience: :was_not_available)

      Fabricate(:facility_review, space: space_with_toilet, facility: kitchen)
      Fabricate(:facility_review, space: space_with_toilet, facility: shower)
      Fabricate(:facility_review, space: space_with_toilet, facility: toilet)

      space_without_toilet.aggregate_facility_reviews
      space_with_toilet.aggregate_facility_reviews
    end

    context "with kitchen" do
      let(:facilities) { [kitchen.id] }

      it "when both spaces have kitchen" do
        expect(filtered_spaces.count).to eq(2)
      end
    end

    context "with toilet" do
      let(:facilities) { [toilet.id] }

      it "when only one space have toilet" do
        expect(filtered_spaces.count).to eq(1)
      end
    end

    context "with kitchen & toilet" do
      let(:facilities) { [kitchen.id, toilet.id] }

      it "when both spaces has either kitchen or toilet" do
        expect(filtered_spaces.count).to eq(2)
      end

      it "with correct order" do
        expect(filtered_spaces.first).to eq(space_with_toilet)
      end
    end
  end

  describe "filter on space types" do
    subject { described_class.filter_on_space_types(space_types).count }

    let(:space_type_a) { Fabricate(:space_type, type_name: "A") }
    let(:space_type_b) { Fabricate(:space_type, type_name: "B") }
    let(:space_type_c) { Fabricate(:space_type, type_name: "C") }

    before do
      Fabricate(:space, space_types: [space_type_b])
      Fabricate(:space, space_types: [space_type_b])
      Fabricate(:space, space_types: [space_type_a])
    end

    context "when only type A" do
      let(:space_types) { [space_type_a.id] }

      it { is_expected.to eq(1) }
    end

    context "when only type B" do
      let(:space_types) { [space_type_b.id] }

      it { is_expected.to eq(2) }
    end

    context "when type A and B" do
      let(:space_types) { [space_type_a.id, space_type_b.id] }

      it { is_expected.to eq(3) }
    end

    context "when type C none" do
      let(:space_types) { [space_type_c.id] }

      it { is_expected.to be_zero }
    end
  end

  describe "paper trails for space" do
    let(:space) { Fabricate(:space) }

    it "when changing field, create a new version" do
      expect(space.versions.count).to eq(1)
      space.update(title: "Hello World")
      expect(space.versions.count).to eq(2)
      expect(space.versions.last.event).to eq("update")
    end
  end

  describe "Image upload" do
    let(:space) { Fabricate(:space) }
    let(:image) { Fabricate(:image, space:) }

    it "allows image to be attached" do
      expect(image.image).to be_attached
      expect(space.images.count).to eq(1)
    end
  end

  describe "Geo data" do
    let(:space) { Fabricate(:space) }

    it "generates a geo point from lng lat" do
      expect(space.geo_point).to be_truthy
      expect(space.geo_point.y).to eq(space.lat)
      expect(space.geo_point.x).to eq(space.lng)
    end

    it "cannot create a space with a lng lat of 0" do
      space.lng = 0
      space.lat = 0
      expect(space).not_to be_valid
    end
  end
end

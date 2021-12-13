# frozen_string_literal: true

require "rails_helper"

RSpec.describe Space, type: :model do
  it "can create a space" do
    expect(Fabricate(:space)).to be_truthy
  end

  describe "filter on factilites" do
    subject(:filter_subject) { described_class.filter_on_facilities(described_class.all, facilities) }

    let(:space1) { Fabricate(:space) }
    let(:space2) { Fabricate(:space) }
    let(:kitchen) { Fabricate(:facility, title: "kitchen") }
    let(:toilet) { Fabricate(:facility, title: "toilet") }
    let(:shower) { Fabricate(:facility, title: "shower") }

    before do
      review_space1 = Fabricate(:review, space: space1)
      review_space2 = Fabricate(:review, space: space2)

      Fabricate(:facility_review, space: space1, review: review_space1, facility: kitchen)
      Fabricate(:facility_review, space: space1, review: review_space1, facility: shower)
      Fabricate(:facility_review, space: space1, review: review_space1, facility: toilet,
                                  experience: :was_not_available)

      Fabricate(:facility_review, space: space2, review: review_space2, facility: kitchen)
      Fabricate(:facility_review, space: space2, review: review_space2, facility: shower)
      Fabricate(:facility_review, space: space2, review: review_space2, facility: toilet)

      space1.aggregate_facility_reviews
      space2.aggregate_facility_reviews
    end

    context "with kitchen" do
      let(:facilities) { [kitchen.id] }

      it "when both spaces have kitchen" do
        expect(filter_subject.count).to eq(2)
      end
    end

    context "with toilet" do
      let(:facilities) { [toilet.id] }

      it "when only one space have toilet" do
        expect(filter_subject.count).to eq(2)
      end
    end

    context "with kitchen & toilet" do
      let(:facilities) { [kitchen.id, toilet.id] }

      it "when both spaces has either kitchen or toilet" do
        expect(filter_subject.count).to eq(2)
      end

      it "with correct order" do
        expect(filter_subject.first).to eq(space2)
      end
    end
  end

  describe "filter on space types" do
    subject { described_class.filter_on_space_types(space_types).count }

    let(:space_type_a) { Fabricate(:space_type, type_name: "A") }
    let(:space_type_b) { Fabricate(:space_type, type_name: "B") }
    let(:space_type_c) { Fabricate(:space_type, type_name: "C") }

    before do
      Fabricate(:space, space_type: space_type_b)
      Fabricate(:space, space_type: space_type_b)
      Fabricate(:space, space_type: space_type_a)
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
end

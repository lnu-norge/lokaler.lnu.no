# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Space, type: :model do

  describe 'filter on space types' do
    subject { Space.filter_on_space_types(space_types).count }

    let(:space_type_a) { Fabricate(:space_type, type_name: 'A') }
    let(:space_type_b) { Fabricate(:space_type, type_name: 'B') }
    let(:space_type_c) { Fabricate(:space_type, type_name: 'C') }

    before do
      Fabricate(:space, space_type: space_type_b)
      Fabricate(:space, space_type: space_type_b)
      Fabricate(:space, space_type: space_type_a)
    end

    context 'when only type A' do
      let(:space_types) { [space_type_a.id] }

      it { is_expected.to eq(1) }
    end

    context 'when only type B' do
      let(:space_types) { [space_type_b.id] }

      it { is_expected.to eq(2) }
    end

    context 'when type A and B' do
      let(:space_types) { [space_type_a.id, space_type_b.id] }

      it { is_expected.to eq(3) }
    end

    context 'when type C none' do
      let(:space_types) { [space_type_c.id] }

      it { is_expected.to be_zero }
    end
  end
end

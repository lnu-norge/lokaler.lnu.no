# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'space_owners/show', type: :view do
  let(:space_owner) { Fabricate :space_owner }

  it 'renders the page' do
    assign(:space_owner, space_owner)
    render

    expect(rendered).to match /#{space_owner.orgnr}/
    expect(rendered).to match /#{space_owner.title}/
    expect(rendered).to match /#{space_owner.about}/
    expect(rendered).to match /#{space_owner.how_to_book}/
    expect(rendered).to match /#{space_owner.terms}/
    expect(rendered).to match /#{space_owner.pricing}/
    expect(rendered).to match /#{space_owner.who_can_use}/
  end
end

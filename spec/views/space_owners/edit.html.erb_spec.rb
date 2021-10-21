# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'space_owners/edit', type: :view do
  let(:space_owner) { Fabricate :space_owner }

  it 'renders the page' do
    assign(:space_owner, space_owner)
    render

    expect(rendered).to match /form/
    expect(rendered).to match /#{space_owner.title}/
    expect(rendered).to match /#{space_owner.orgnr}/
    expect(rendered).to match /space_owner_how_to_book/
    expect(rendered).to match /space_owner_terms/
    expect(rendered).to match /space_owner_pricing/
    expect(rendered).to match /space_owner_who_can_use/
    expect(rendered).to match /space_owner_about/
    expect(rendered).to match /submit/
  end
end

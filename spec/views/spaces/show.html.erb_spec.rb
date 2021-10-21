# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'spaces/show', type: :view do
  let(:space) { Fabricate :space }

  it 'renders the page' do
    assign(:space, space)
    render

    expect(rendered).to match /h1/
    expect(rendered).to match /#{space.title}/
    expect(rendered).to match /space_#{space.id}-how_to_book/
    expect(rendered).to match /space_#{space.id}-who_can_use/
    expect(rendered).to match /space_#{space.id}-pricing/
    expect(rendered).to match /space_#{space.id}-address/
    expect(rendered).to match /space_#{space.id}-more_info/
    expect(rendered).to match /space_#{space.id}-terms/
  end
end

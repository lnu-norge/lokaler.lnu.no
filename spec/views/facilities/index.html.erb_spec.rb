# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'facilities/index.html.erb', type: :view do
  let(:facilities) { Fabricate.times(3, :facility) }

  xit 'renders the page' do
    assign(:facilities, facilities)
    render

    expect(rendered).to match /h1/
    expect(rendered).to match /form/
    expect(rendered).to match /h2/

    # Something is wrong with these - please have a look if you see this
    expect(rendered).to match /#{facilities.first.title}/
    expect(rendered).to match /#{facilities.second.title}/
    expect(rendered).to match /#{facilities.third.title}/
  end
end

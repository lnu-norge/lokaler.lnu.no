# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'facilities/index.html.erb', type: :view do
  let(:facilities) { Fabricate.times(3, :facility) }

  it 'renders the page' do
    assign(:facilities, facilities)
    assign(:facilty, Facility.new)
    render

    expect(rendered).to match /h1/
    expect(rendered).to match /form/
    expect(rendered).to match /h2/

    expect(rendered).to match /#{facilities.first.title}/
    expect(rendered).to match /#{facilities.second.title}/
    expect(rendered).to match /#{facilities.third.title}/
  end
end

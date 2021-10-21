# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'facilities/show.html.erb', type: :view do
  let(:facility) { Fabricate :facility }

  xit 'renders the page' do
    assign(:facility, facility)
    render

    expect(rendered).to match /h1/
    expect(rendered).to match /#{facility.title}/
  end
end

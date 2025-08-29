# frozen_string_literal: true

require "rails_helper"

RSpec.describe Facility, type: :model do
  it "can create a facility" do
    expect(Fabricate(:facility)).to be_truthy
  end
end

# == Schema Information
#
# Table name: facilities
#
#  id         :bigint           not null, primary key
#  icon       :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

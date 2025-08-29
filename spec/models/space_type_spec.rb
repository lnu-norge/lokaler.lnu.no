# frozen_string_literal: true

require "rails_helper"

RSpec.describe SpaceType, type: :model do
  it "can create a spaceType" do
    expect(Fabricate(:space_type)).to be_truthy
  end
end

# == Schema Information
#
# Table name: space_types
#
#  id         :bigint           not null, primary key
#  type_name  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

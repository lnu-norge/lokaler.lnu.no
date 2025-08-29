# frozen_string_literal: true

require "rails_helper"

RSpec.describe SpaceGroup, type: :model do
  it "can create a spaceGroup" do
    expect(Fabricate(:space_group)).to be_truthy
  end
end

# == Schema Information
#
# Table name: space_groups
#
#  id         :bigint           not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

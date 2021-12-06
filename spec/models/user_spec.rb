# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  it "can create a user" do
    expect(Fabricate(:user)).to be_truthy
  end

  it "returns the right name" do
    only_first_name = Fabricate(:user,
                                first_name: "Ola",
                                last_name: "")
    expect(only_first_name.name).to eq "Ola"

    only_last_name = Fabricate(:user,
                               first_name: "",
                               last_name: "Nordmann")
    expect(only_last_name.name).to eq "Nordmann"

    both_names = Fabricate(:user,
                           first_name: "Ola",
                           last_name: "Nordmann")
    expect(both_names.name).to eq "Ola N."
  end
end

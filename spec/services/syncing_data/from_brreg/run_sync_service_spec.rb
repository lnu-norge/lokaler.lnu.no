# frozen_string_literal: true

require "rails_helper"
require "webmock/rspec"

RSpec.describe SyncingData::FromBrreg::RunSyncService do
  let(:service) { described_class.new }
  let(:base_uri) { "https://data.brreg.no/enhetsregisteret/api" }
  let(:enhet_endpoint) { "#{base_uri}/enheter" }
  let(:underenhet_endpoint) { "#{base_uri}/underenheter" }
  let(:logger_with_tags) { service.send(:logger) }
  let(:invalid_org_number) { "123456789" }
  let(:valid_org_number) { "975283046" }
  let(:no_org_number) { nil }

  before do
    Fabricate(:space, organization_number: invalid_org_number)
    Fabricate(:space, organization_number: valid_org_number)
    Fabricate(:space, organization_number: no_org_number)
    VCR.insert_cassette "brreg/sync"
  end

  after do
    VCR.eject_cassette
  end

  describe "#call" do
    it "fetches all the right enhet and underenhet endpoints for spaces with organization numbers" do
      # Set up spy
      allow(HTTP).to receive(:get).and_call_original

      service.call

      # We should have called the enhet API twice, once for each org number
      expect(HTTP).to have_received(:get)
        .with(/#{enhet_endpoint}/)
        .exactly(:twice)
      # We should have called the underenhet API twice, once for each org number
      expect(HTTP).to have_received(:get)
        .with(/#{underenhet_endpoint}/)
        .exactly(:twice)

      # And we should have called the enhet API for each org number
      expect(HTTP).to have_received(:get)
        .with("#{enhet_endpoint}/#{invalid_org_number}")
        .once
      expect(HTTP).to have_received(:get)
        .with("#{enhet_endpoint}/#{valid_org_number}")
        .once

      # As well as the underenhet API for each org number
      expect(HTTP).to have_received(:get)
        .with("#{underenhet_endpoint}/#{invalid_org_number}")
        .once
      expect(HTTP).to have_received(:get)
        .with("#{underenhet_endpoint}/#{valid_org_number}")
        .once

      # And not for the ones that don't have org numbers
      expect(HTTP).not_to have_received(:get)
        .with("#{enhet_endpoint}/#{no_org_number}")

      expect(HTTP).not_to have_received(:get)
        .with("#{enhet_endpoint}/")
    end
  end

  describe "#contact_information_for" do
    it "fetches and returns fresh contact information for an organization number" do
      # Set up spy
      allow(HTTP).to receive(:get).and_call_original

      raw_contact_information = service.send(:raw_contact_information_from_brreg_for, org_number: valid_org_number)

      expect(HTTP).to have_received(:get)
        .with("#{enhet_endpoint}/#{valid_org_number}")
        .once

      expect(raw_contact_information[:email]).to eq("postmottak@gjerstad.kommune.no")
      expect(raw_contact_information[:phone]).to eq("37119785")
      expect(raw_contact_information[:mobile]).to eq("45035139")
      expect(raw_contact_information[:website]).to eq("www.abel.skole.no")
    end
  end
end

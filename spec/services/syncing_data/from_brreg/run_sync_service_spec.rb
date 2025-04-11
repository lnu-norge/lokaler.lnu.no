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
  end

  around do |example|
    VCR.use_cassette("brreg/sync") do
      example.run
    end
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
    context "when fetching and returning" do
      it "for an organization number" do
        # Set up spy
        allow(HTTP).to receive(:get).and_call_original

        contact_information = service.send(:contact_information_from_brreg_for, org_number: valid_org_number)

        expect(HTTP).to have_received(:get)
          .with("#{enhet_endpoint}/#{valid_org_number}")
          .once

        expect(contact_information[:email]).to eq("postmottak@gjerstad.kommune.no")
        expect(contact_information[:phone]).to eq("37119785")
        expect(contact_information[:mobile]).to eq("45035139")
        expect(contact_information[:website]).to eq("http://www.abel.skole.no")
      end
    end

    context "when parsing email" do
      it "skips empty emails" do
        parsed_email = service.send(:parse_email, "")
        expect(parsed_email).to be_nil
      end

      it "valid email go through" do
        parsed_email = service.send(:parse_email, "postmottak@gjerstad.kommune.no")
        expect(parsed_email).to eq("postmottak@gjerstad.kommune.no")
      end

      it "emails with spaces are stripped" do
        parsed_email = service.send(:parse_email, "  postmottak@gjerstad.kommune.no ")
        expect(parsed_email).to eq("postmottak@gjerstad.kommune.no")
      end

      it "invalid emails without @ are skipped" do
        parsed_email = service.send(:parse_email, "postmottakgjerstad.kommune.no")
        expect(parsed_email).to be_nil
      end

      it "invalid emails without domain are skipped" do
        parsed_email = service.send(:parse_email, "postmottak@")
        expect(parsed_email).to be_nil
      end

      it "invalid emails without denomination are skipped" do
        parsed_email = service.send(:parse_email, "@gjerstad.kommune.no")
        expect(parsed_email).to be_nil
      end
    end

    context "when parsing phone numbers" do
      it "skips empty phone numbers" do
        parsed_phone = service.send(:parse_phone, "")
        expect(parsed_phone).to be_nil
      end

      it "phone numbers with spaces are stripped" do
        parsed_phone = service.send(:parse_phone, "  +47 999 99 99 ")
        expect(parsed_phone).to eq("+479999999")
      end
    end

    context "when parsing urls" do
      it "skips empty urls" do
        parsed_url = service.send(:parse_url, "")
        expect(parsed_url).to be_nil
      end

      it "strips spaces from urls" do
        parsed_url = service.send(:parse_url, "  https://example.com ")
        expect(parsed_url).to eq("https://example.com")
      end

      it "does not strip spaces inside urls" do
        parsed_url = service.send(:parse_url, "https://example.com/path /to/file.html")
        expect(parsed_url).to eq("https://example.com/path /to/file.html")
      end

      it "adds http to urls without http or https" do
        parsed_url = service.send(:parse_url, "example.com")
        expect(parsed_url).to eq("http://example.com")
      end
    end
  end
end

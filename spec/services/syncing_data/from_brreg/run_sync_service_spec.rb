# frozen_string_literal: true

require "rails_helper"
require "webmock/rspec"

RSpec.describe SyncingData::FromBrreg::RunSyncService do
  let(:service) { described_class.new }
  let(:base_uri) { "https://data.brreg.no/enhetsregisteret/api" }
  let(:enhet_endpoint) { "#{base_uri}/enheter" }
  let(:underenhet_endpoint) { "#{base_uri}/underenheter" }
  let!(:brreg_robot_user_id) { Robot.brreg.id.to_s }
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

    it "logs sync status for each org number" do
      expect(SyncStatus.count).to eq(0)

      service.call

      expect(SyncStatus.count).to eq(2)

      valid_sync_status = SyncStatus.for(id_from_source: valid_org_number, source: "brreg")
      invalid_sync_status = SyncStatus.for(id_from_source: invalid_org_number, source: "brreg")

      expect(valid_sync_status.last_successful_sync_at).not_to be_nil
      expect(invalid_sync_status.last_successful_sync_at).to be_nil
    end

    it "logs changes in paper trail" do
      expect { service.call }.to change(PaperTrail::Version, :count).by(2) # Two new space contacts
      expect(PaperTrail::Version.last.whodunnit).to eq(brreg_robot_user_id)
    end
  end

  describe "#sync_space_contacts_for" do
    context "when no space contacts exist" do
      it "creates two new space contacts if both mobile and phone is set" do
        space_contacts = Space.find_by(organization_number: valid_org_number).space_contacts

        expect(space_contacts.count).to eq(0)

        service.call

        space_contacts.reload
        expect(space_contacts.count).to eq(2)
        expect(space_contacts.first.title).to eq("Sentralbord")
        expect(space_contacts.first.telephone).to eq("37119785")
        expect(space_contacts.first.email).to eq("postmottak@gjerstad.kommune.no")
        expect(space_contacts.first.url).to eq("http://www.abel.skole.no")

        expect(space_contacts.second.title).to eq("Sentralbord (mobil)")
        expect(space_contacts.second.telephone).to eq("45035139")
        expect(space_contacts.second.email).to be_nil
        expect(space_contacts.second.url).to be_nil
      end

      it "creates one space contact if only mobile is set" do
        space_contacts = Space.find_by(organization_number: valid_org_number).space_contacts

        expect(space_contacts.count).to eq(0)

        # Inject a response with only mobile number for Abel
        allow(service).to receive(:contact_information_from_brreg_for).and_call_original
        allow(service).to receive(:contact_information_from_brreg_for)
          .with(org_number: valid_org_number)
          .and_return({
                        email: "postmottak@gjerstad.kommune.no",
                        phone: nil,
                        mobile: "45035139",
                        website: "http://www.abel.skole.no"
                      })

        service.call

        space_contacts.reload
        expect(space_contacts.count).to eq(1)
        expect(space_contacts.first.title).to eq("Sentralbord")
        expect(space_contacts.first.telephone).to eq("45035139")
        expect(space_contacts.first.email).to eq("postmottak@gjerstad.kommune.no")
        expect(space_contacts.first.url).to eq("http://www.abel.skole.no")
      end

      it "creates no space contacts for invalid org numbers" do
        space_contacts = Space.find_by(organization_number: invalid_org_number).space_contacts

        expect(space_contacts.count).to eq(0)

        # Inject a response with only mobile number for Abel
        service.call

        space_contacts.reload
        expect(space_contacts.count).to eq(0)
      end

      it "updates existing Sentralbord space contact if it exists" do
        space = Space.find_by(organization_number: valid_org_number)
        old_space_contact = space.space_contacts.create!(
          title: "Sentralbord Abel skole",
          email: "old_postmottak@gjerstad.kommune.no",
          telephone: "22225555",
          url: "http://www.old.abel.skole.no"
        )

        service.call

        expect(space.space_contacts.count).to eq(2)
        expect(space.space_contacts.first.id).to eq(old_space_contact.id)
        expect(space.space_contacts.first.title).to eq("Sentralbord")
        expect(space.space_contacts.first.telephone).to eq("37119785")
        expect(space.space_contacts.first.email).to eq("postmottak@gjerstad.kommune.no")
        expect(space.space_contacts.first.url).to eq("http://www.abel.skole.no")
        expect(space.space_contacts.first.versions.last.whodunnit).to eq(Robot.brreg.id)

        expect(space.space_contacts.second.title).to eq("Sentralbord (mobil)")
        expect(space.space_contacts.second.telephone).to eq("45035139")
        expect(space.space_contacts.second.email).to be_nil
        expect(space.space_contacts.second.url).to be_nil
      end

      it "does not overwrite data that has been written by a human, but does add missing data" do
        space = Space.find_by(organization_number: valid_org_number)
        human_user = Fabricate(:user)
        PaperTrail.request(whodunnit: human_user.id) do
          space.space_contacts.create!(
            title: "Sentralbord Abel skole",
            email: "menneske@gjerstad.kommune.no",
            url: "http://www.old.abel.skole.no"
          )
        end

        service.call

        expect(space.space_contacts.count).to eq(2)
        expect(space.space_contacts.first.title).to eq("Sentralbord Abel skole")
        expect(space.space_contacts.first.telephone).to eq("37119785")
        expect(space.space_contacts.first.email).to eq("menneske@gjerstad.kommune.no")
        expect(space.space_contacts.first.url).to eq("http://www.old.abel.skole.no")
        expect(space.space_contacts.first.versions.last.whodunnit).to eq(brreg_robot_user_id)
        expect(space.space_contacts.second.title).to eq("Sentralbord (Mobil)")
        expect(space.space_contacts.second.telephone).to eq("45035139")
        expect(space.space_contacts.second.email).to be_nil
        expect(space.space_contacts.second.url).to be_nil
      end

      it "does not add data that is already set in some other non-sentralbord space contact" do
        space = Space.find_by(organization_number: valid_org_number)
        old_space_contact = space.space_contacts.create!(
          title: "Kontaktinfo til Abel skole",
          email: "postmottak@gjerstad.kommune.no"
        )

        service.call

        expect(space.space_contacts.count).to eq(3)
        expect(space.space_contacts.first.id).to eq(old_space_contact.id)
        expect(space.space_contacts.second.title).to eq("Sentralbord")
        expect(space.space_contacts.second.telephone).to eq("37119785")
        expect(space.space_contacts.second.email).to be_blank
        expect(space.space_contacts.second.url).to eq("http://www.abel.skole.no")

        expect(space.space_contacts.third.title).to eq("Sentralbord (mobil)")
        expect(space.space_contacts.third.telephone).to eq("45035139")
        expect(space.space_contacts.third.email).to be_blank
        expect(space.space_contacts.third.url).to be_blank
      end

      it "does not update data has previously been set in some version of an existing space contact" do
        space = Space.find_by(organization_number: valid_org_number)
        old_space_contact = space.space_contacts.create!(
          title: "Sentralbord Abel skole",
          email: "postmottak@gjerstad.kommune.no"
        )
        PaperTrail.request(whodunnit: Fabricate(:user).id) do
          old_space_contact.update!(email: "new_email@example.com")
        end

        service.call

        expect(space.space_contacts.count).to eq(2)
        expect(space.space_contacts.first.id).to eq(old_space_contact.id)
        expect(space.space_contacts.first.title).to eq("Sentralbord")
        expect(space.space_contacts.first.telephone).to eq("37119785")
        expect(space.space_contacts.first.email).to eq("new_email@example.com")
        expect(space.space_contacts.first.url).to eq("http://www.abel.skole.no")
      end

      it "does not update data that was already set in a previously deleted space contact for this space" do
        space = Space.find_by(organization_number: valid_org_number)
        old_space_contact = space.space_contacts.create!(
          title: "Sentralbord Abel skole",
          email: "postmottak@gjerstad.kommune.no"
        )
        PaperTrail.request(whodunnit: Fabricate(:user).id) do
          old_space_contact.destroy
        end

        service.call

        expect(space.space_contacts.count).to eq(2)
        expect(space.space_contacts.first.title).to eq("Sentralbord")
        expect(space.space_contacts.first.telephone).to eq("37119785")
        expect(space.space_contacts.first.email).to be_blank
        expect(space.space_contacts.first.url).to eq("http://www.abel.skole.no")
      end
    end
  end

  describe "#contact_information_for" do
    context "when fetching and returning" do
      it "returns the right information" do
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

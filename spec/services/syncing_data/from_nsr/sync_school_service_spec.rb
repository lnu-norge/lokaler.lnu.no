# frozen_string_literal: true

require "rails_helper"
require "webmock/rspec"

RSpec.describe SyncingData::FromNsr::SyncSchoolService do
  let(:nsr_base_uri) { "https://data-nsr.udir.no/v4/" }
  let(:nsr_uri_enhet) { "#{nsr_base_uri}enhet" }
  let!(:nsr_robot_user_id) { Robot.nsr.id.to_s }
  let(:org_number) { "975283046" } # Abel skole
  let(:date_changed_at_from_nsr) { "2025-03-21T08:38:18.143+01:00" }
  let(:service) { described_class.new(org_number: org_number, date_changed_at_from_nsr: date_changed_at_from_nsr) }
  let(:logger_with_tags) { service.send(:logger) }

  before do
    # Clear the cache before each test
    Rails.cache.clear
    Fabricate(:space_type, type_name: "Grunnskole")
    Fabricate(:space_type, type_name: "VGS")
    Fabricate(:space_type, type_name: "Folkehøgskole")

    # Clear database state that might interfere with tests
    Admin::SyncStatus.destroy_all
  end

  describe "#call" do
    context "when school needs syncing", :vcr do
      it "fetches school details and processes them" do
        allow(service).to receive(:details_about_school).and_call_original
        allow(service).to receive(:process_school_and_save_space_data).and_call_original

        VCR.use_cassette("nsr/enhet/public_school_abel") do
          result = service.call
          expect(result).to be_a(Space)
          expect(result.organization_number).to eq(org_number)
          expect(service).to have_received(:details_about_school).with(
            org_number: org_number,
            date_changed_at_from_nsr: date_changed_at_from_nsr
          )
          expect(service).to have_received(:process_school_and_save_space_data)
        end
      end
    end
  end

  describe "caching behaviour integration tests", :vcr do
    # Clear cache between tests to avoid test pollution
    before do
      Rails.cache.clear
    end

    it "caches school details and uses cache on subsequent requests" do
      # Set up HTTP tracking
      allow(HTTP).to receive(:get).and_call_original
      http_url = "#{SyncingData::FromNsr::NSR_BASE_URL}/enhet/#{org_number}"

      # Set up cache tracking
      allow(Rails.cache).to receive(:read).and_call_original
      allow(Rails.cache).to receive(:write).and_call_original

      # First call should fetch data and cache it
      VCR.use_cassette("nsr/enhet/#{org_number}") do
        result_before_cache = service.send(:details_about_school, org_number: org_number,
                                                                  date_changed_at_from_nsr: date_changed_at_from_nsr)
        expect(result_before_cache).to be_present
        expect(result_before_cache["Organisasjonsnummer"]).to eq(org_number)
        expect(Rails.cache).to have_received(:read).once
        expect(Rails.cache).to have_received(:write).once

        # Second call should use the cache
        result_after_cache = service.send(:details_about_school, org_number: org_number,
                                                                 date_changed_at_from_nsr: date_changed_at_from_nsr)
        expect(result_after_cache).to eq(result_before_cache)
        expect(Rails.cache).to have_received(:read).twice # one for each call
        expect(Rails.cache).to have_received(:write).twice # Resets date for cache

        # Verify HTTP was called only once
        expect(HTTP).to have_received(:get).with(http_url).once
      end
    end

    it "uses cache when data has not changed" do
      # First call to populate cache
      VCR.use_cassette("nsr/enhet/#{org_number}", allow_playback_repeats: true) do
        # Set up cache manually to ensure date_changed_at_from_nsr matching
        test_data = { "Organisasjonsnummer" => org_number, "DatoEndret" => "2025-03-21T08:38:18.143+01:00" }
        cache_data = {
          data: test_data,
          date_changed_at_from_nsr: "2025-03-21T08:38:18.143+01:00",
          cached_at: Time.current.iso8601
        }
        Rails.cache.write("nsr:school:#{org_number}", cache_data)

        # Set up HTTP tracking
        allow(HTTP).to receive(:get).and_call_original

        # Call with matching date - should use cache
        result = service.send(:details_about_school,
                              org_number: org_number,
                              date_changed_at_from_nsr: "2025-03-21T08:38:18.143+01:00")

        # Verify result matches cached data
        expect(result).to eq(test_data)

        # HTTP is not called, so we expect the cache to be used
        expect(HTTP).not_to have_received(:get)
      end
    end
  end

  describe "#details_about_school" do
    context "when the API call is successful", :vcr do
      it "fetches detailed information for a school" do
        # Clear the cache explicitly for this test
        Rails.cache.clear

        VCR.use_cassette("nsr/enhet/#{org_number}") do
          school_details = service.send(:details_about_school,
                                        org_number: org_number,
                                        date_changed_at_from_nsr: date_changed_at_from_nsr)

          # Verify the response contains expected data
          expect(school_details).to be_a(Hash)
          expect(school_details["Organisasjonsnummer"]).to eq(org_number)
          expect(school_details).to include("Navn", "Beliggenhetsadresse", "Kommune")
        end
      end
    end

    context "when the API call fails" do
      let(:error_response) do
        instance_double(HTTP::Response::Status, success?: false, code: 404, to_s: "404 Not Found")
      end

      let(:error_body) do
        instance_double(HTTP::Response::Body, to_s: "Not Found")
      end

      before do
        allow(HTTP).to receive(:get).with("#{nsr_uri_enhet}/#{org_number}").and_return(
          instance_double(HTTP::Response, status: error_response, body: error_body)
        )
        allow(service).to receive(:logger).and_return(logger_with_tags)
        allow(logger_with_tags).to receive(:error)
      end

      it "raises an API error and logs it" do
        # Allow the cache methods to maintain test isolation
        allow(service).to receive(:cache_still_fresh?).and_return(false)

        expect do
          service.send(:details_about_school, org_number: org_number,
                                              date_changed_at_from_nsr: date_changed_at_from_nsr)
        end.to raise_error(/API Error/)

        expect(logger_with_tags).to have_received(:error).with(/Failed to fetch school details/).at_least(:once)
      end
    end
  end

  context "when processing a school we already have" do
    # Clear cache and ensure database isolation
    before do
      Rails.cache.clear
    end

    let!(:old_space_group_how_to_book) do
      ActionText::Content.new("<p>Existing group how to book</p>")
    end
    let!(:old_space_group_terms_and_pricing) do
      ActionText::Content.new("<p>Existing group terms and pricing</p>")
    end
    let!(:old_space_group_about) do
      ActionText::Content.new("<p>Existing group about</p>")
    end
    let!(:old_space_group) do
      Fabricate(:space_group,
                title: "Old kommune",
                how_to_book: old_space_group_how_to_book,
                terms_and_pricing: old_space_group_terms_and_pricing,
                about: old_space_group_about)
    end
    let!(:old_space_types) do
      [
        Fabricate(:space_type, type_name: "Old type")
      ]
    end
    let!(:space_for_abel) do
      space = Fabricate(:space,
                        organization_number: org_number,
                        address: "Outdated address",
                        space_group: old_space_group,
                        space_types: old_space_types)

      SyncingData::Shared::SafelySyncDataService.new(
        user_or_robot_doing_the_syncing: Fabricate(:user),
        model: space,
        field: :title,
        new_data: "User updated this title of Abel"
      ).safely_sync_data

      space
    end
    let!(:school_details) do
      VCR.use_cassette("nsr/enhet/public_school_abel") do
        service.send(:details_about_school, org_number: org_number, date_changed_at_from_nsr: date_changed_at_from_nsr)
      end
    end
    let!(:synced_space_for_abel) do
      VCR.use_cassette("nsr/enhet/processing_school_abel") do
        service.send(:process_school_and_save_space_data, school_details)
      end
    end

    it "finds the existing space based on organization number" do
      expect(synced_space_for_abel).to eq(space_for_abel)
    end

    it "does not create a new space" do
      expect(Space.pluck(:id)).to contain_exactly(space_for_abel.id)
    end

    it "does not overwrite the user set title" do
      expect(synced_space_for_abel.title).to eq("User updated this title of Abel")
    end

    it "overwrites the robot set address" do
      expect(synced_space_for_abel.address).not_to eq("Outdated address")
      expect(synced_space_for_abel.address).to eq("Gamle Sørlandske 1304")
    end

    it "creates a new space group, as the ownership of the school changed" do
      # Useful for when fylker or kommuner change, and thus the school has changed ownership
      expect(synced_space_for_abel.space_group).to be_present
      expect(synced_space_for_abel.space_group.id).not_to eq(old_space_group.id)
    end

    it "sets the right space group title" do
      expect(synced_space_for_abel.space_group.title).to include("Gjerstad kommune")
    end

    it "preserves old space_group information in the new space group, if it has data already" do
      # The old space group data might still be relevant, even though the school has changed ownership
      # (This also preserves data if the space group just changed names)
      new_space_group = synced_space_for_abel.space_group

      expect(new_space_group.how_to_book.body).to eq(old_space_group_how_to_book)
      expect(new_space_group.terms_and_pricing.body).to eq(old_space_group_terms_and_pricing)
      expect(new_space_group.about.body).to eq(old_space_group_about)
    end

    it "removes unused space groups" do
      expect(SpaceGroup.where(id: old_space_group.id)).to be_empty
    end

    it "combines the old and new space types arrays" do
      expect(synced_space_for_abel.space_types.map(&:type_name)).to contain_exactly("Old type", "Grunnskole")
    end
  end

  context "when processing Abel, a new public school" do
    # Clear cache and ensure database isolation
    before do
      Rails.cache.clear
      Space.where(organization_number: org_number).destroy_all
    end

    # First make sure the school doesn't exist

    let(:public_school_details) do
      VCR.use_cassette("nsr/enhet/public_school_abel") do
        service.send(:details_about_school, org_number: org_number, date_changed_at_from_nsr: date_changed_at_from_nsr)
      end
    end
    let!(:space) do
      VCR.use_cassette("nsr/enhet/processing_school_abel") do
        service.send(:process_school_and_save_space_data, public_school_details)
      end
    end

    it "leaves a paper trail for the space" do
      expect(space.versions.count).not_to eq(0)
      expect(space.versions.last.whodunnit).to eq(nsr_robot_user_id)
    end

    it "leaves a paper trail for the space group" do
      expect(space.space_group.versions.count).not_to eq(0)
      expect(space.space_group.versions.last.whodunnit).to eq(nsr_robot_user_id)
    end

    it "sets the right organization number" do
      expect(space.organization_number).to eq(org_number)
    end

    it "sets the right space type" do
      expect(space.space_types).to include(SpaceType.find_by(type_name: "Grunnskole"))
    end

    it "sets the right space group" do
      expect(space.space_group).to be_present
      expect(space.space_group.title).to include("Gjerstad kommune")
    end

    it "sets the right title" do
      expect(space.title).to eq("Abel skole")
    end

    it "sets the right location" do
      expect(space.address).to eq("Gamle Sørlandske 1304")
      expect(space.post_number).to eq("4993")
      expect(space.lat).to eq(5.88392e1)
      expect(space.lng).to eq(9.09501e0)
    end
  end

  describe "inactive school handling" do
    let(:org_number) { "888888888" }
    let(:date_changed_at_from_nsr) { "2025-03-21T10:00:00.000+01:00" }

    before do
      # Stub the HTTP call to return inactive school data
      stub_request(:get, "#{nsr_base_uri}enhet/#{org_number}")
        .to_return(
          status: 200,
          body: {
            "Organisasjonsnummer" => org_number,
            "Navn" => "Inactive School",
            "FulltNavn" => "Inactive Test School",
            "ErAktiv" => false,
            "ErSkole" => true,
            "ErGrunnskole" => true,
            "DatoEndret" => date_changed_at_from_nsr,
            "Beliggenhetsadresse" => {
              "Adresse" => "Test Street 1",
              "Postnummer" => "0001",
              "Poststed" => "Test City",
              "Land" => "Norge"
            },
            "Koordinat" => {
              "Lengdegrad" => 10.75,
              "Breddegrad" => 59.91,
              "Zoom" => 12,
              "GeoKilde" => "GeoNorge"
            },
            "Kommune" => {
              "Navn" => "Test Kommune",
              "Kommunenummer" => "0001",
              "Organisasjonsnummer" => "999999999",
              "ErNedlagt" => false,
              "Fylkesnummer" => "01"
            },
            "Skolekategorier" => [
              { "Id" => "1", "Navn" => "Grunnskole" }
            ],
            "ForeldreRelasjoner" => [
              {
                "Enhet" => {
                  "Organisasjonsnummer" => "999999999",
                  "Navn" => "Test Kommune"
                },
                "Relasjonstype" => { "Id" => "1", "Navn" => "Eierstruktur" }
              }
            ]
          }.to_json,
          headers: { "Content-Type" => "application/json; charset=utf-8" }
        )
    end

    context "when inactive school already exists in database" do
      let!(:existing_space) { Fabricate(:space, organization_number: org_number, deleted: false) }

      it "sets deleted: true for existing inactive school" do
        service = described_class.new(org_number: org_number, date_changed_at_from_nsr: date_changed_at_from_nsr)

        result = service.call
        existing_space.reload

        expect(result).to eq(existing_space)
        expect(existing_space.deleted).to be true
      end

      it "creates paper trail version tracking deleted status change" do
        service = described_class.new(org_number: org_number, date_changed_at_from_nsr: date_changed_at_from_nsr)

        expect { service.call }.to(change(PaperTrail::Version, :count))

        # Find the version that tracked the deleted field change
        deleted_version = PaperTrail::Version.where(item: existing_space)
                                             .where("object_changes LIKE '%deleted%'")
                                             .last
        existing_space.reload
        expect(deleted_version).to be_present
        changes = YAML.unsafe_load(deleted_version.object_changes)
        expect(changes["deleted"]).to eq([false, true])
        expect(deleted_version.whodunnit).to eq(Robot.nsr.id.to_s)
      end

      it "allows reverting deleted status through paper trail" do
        service = described_class.new(org_number: org_number, date_changed_at_from_nsr: date_changed_at_from_nsr)

        service.call
        existing_space.reload
        expect(existing_space.deleted).to be true

        # Revert to previous version
        version = PaperTrail::Version.last
        previous_version = version.previous
        existing_space.update!(previous_version.reify.attributes.slice("deleted"))

        expect(existing_space.deleted).to be false
      end
    end

    context "when inactive school does not exist in database" do
      let(:nonexistent_org_number) { "777777777" }

      before do
        # Additional stub for the non-existent school
        stub_request(:get, "#{nsr_base_uri}enhet/#{nonexistent_org_number}")
          .to_return(
            status: 200,
            body: {
              "Organisasjonsnummer" => nonexistent_org_number,
              "Navn" => "Another Inactive School",
              "FulltNavn" => "Another Inactive Test School",
              "ErAktiv" => false,
              "ErSkole" => true,
              "ErGrunnskole" => true,
              "DatoEndret" => date_changed_at_from_nsr,
              "Beliggenhetsadresse" => {
                "Adresse" => "Test Street 2",
                "Postnummer" => "0002",
                "Poststed" => "Test City 2",
                "Land" => "Norge"
              },
              "Koordinat" => {
                "Lengdegrad" => 11.75,
                "Breddegrad" => 60.91,
                "Zoom" => 12,
                "GeoKilde" => "GeoNorge"
              },
              "Kommune" => {
                "Navn" => "Test Kommune 2",
                "Kommunenummer" => "0002",
                "Organisasjonsnummer" => "888888888",
                "ErNedlagt" => false,
                "Fylkesnummer" => "02"
              },
              "Skolekategorier" => [
                { "Id" => "1", "Navn" => "Grunnskole" }
              ],
              "ForeldreRelasjoner" => [
                {
                  "Enhet" => {
                    "Organisasjonsnummer" => "888888888",
                    "Navn" => "Test Kommune 2"
                  },
                  "Relasjonstype" => { "Id" => "1", "Navn" => "Eierstruktur" }
                }
              ]
            }.to_json,
            headers: { "Content-Type" => "application/json; charset=utf-8" }
          )
      end

      it "does not create new space and does not create paper trail versions" do
        initial_space_count = Space.count
        initial_version_count = PaperTrail::Version.count

        service = described_class.new(org_number: nonexistent_org_number,
                                      date_changed_at_from_nsr: date_changed_at_from_nsr)
        result = service.call

        # No new space should be created
        expect(Space.count).to eq(initial_space_count)
        expect(Space.find_by(organization_number: nonexistent_org_number)).to be_nil

        # No paper trail versions should be created (no changes made)
        expect(PaperTrail::Version.count).to eq(initial_version_count)

        # Service should return nil (indicating no sync occurred)
        expect(result).to be_nil
      end
    end
  end
end

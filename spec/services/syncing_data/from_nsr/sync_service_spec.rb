# frozen_string_literal: true

require "rails_helper"
require "webmock/rspec"

RSpec.describe SyncingData::FromNsr::SyncService do
  let(:nsr_base_uri) { "https://data-nsr.udir.no/v4/" }
  let(:nsr_uri_skoler_per_skolekategori) { "#{nsr_base_uri}enheter/skolekategori" }
  let(:nsr_uri_enhet) { "#{nsr_base_uri}enhet" }
  let!(:nsr_robot_user_id) { Robot.nsr.id.to_s }

  before do
    # Set up the needed SpaceTypes
    Fabricate(:space_type, type_name: "Grunnskole")
    Fabricate(:space_type, type_name: "VGS")
    Fabricate(:space_type, type_name: "Folkehøgskole")
  end

  describe "#filter_schools" do
    let(:service) { described_class.new }
    let(:inactive_school) { { "ErAktiv" => false, "Organisasjonsnummer" => "123456789" } }
    let(:active_school) { { "ErAktiv" => true, "Organisasjonsnummer" => "987654321" } }
    let(:inactive_school_no_orgnr) { { "ErAktiv" => false } }
    let(:inactive_school_existing) { { "ErAktiv" => false, "Organisasjonsnummer" => "555555555" } }
    let(:school_with_no_new_data_since_last_sync) do
      { "Organisasjonsnummer" => "444444444", "Navn" => "Already synced school",
        "DatoEndret" => "2022-04-08T08:38:18.143+01:00" }
    end
    let(:space_for_already_synced_school) { Fabricate(:space, organization_number: "444444444") }

    before do
      # Create a space with organization_number matching inactive_school_existing
      Fabricate(:space, organization_number: "555555555")
    end

    it "keeps active schools regardless of organization number" do
      schools = [active_school]
      result = service.send(:select_relevant_schools_from_list, schools)
      expect(result).to eq([active_school])
    end

    it "filters out inactive schools with no matching spaces" do
      schools = [inactive_school]
      result = service.send(:select_relevant_schools_from_list, schools)
      expect(result).to be_empty
    end

    it "keeps inactive schools with organization numbers that already exist in spaces" do
      schools = [inactive_school_existing]
      result = service.send(:select_relevant_schools_from_list, schools)
      expect(result).to eq([inactive_school_existing])
    end

    it "filters out inactive schools with no organization number" do
      schools = [inactive_school_no_orgnr]
      result = service.send(:select_relevant_schools_from_list, schools)
      expect(result).to be_empty
    end

    it "filters out schools that have no new data since last successful sync" do
      SyncStatus
        .for_space(space_for_already_synced_school, source: "nsr")
        .log_success

      schools = [school_with_no_new_data_since_last_sync]
      result = service.send(:select_relevant_schools_from_list, schools)
      expect(result).to be_empty
    end

    it "correctly handles a mix of schools" do
      schools = [active_school, inactive_school, inactive_school_existing, inactive_school_no_orgnr]
      result = service.send(:select_relevant_schools_from_list, schools)
      expect(result).to contain_exactly(active_school, inactive_school_existing)
    end
  end

  describe "#call" do
    let(:service) { described_class.new }

    context "with real API responses", :vcr do
      let(:success_response) do
        instance_double(HTTP::Response::Status, success?: true)
      end

      let(:empty_body) do
        instance_double(HTTP::Response::Body, to_s: "[]")
      end

      it "fetches at least 10 schools from Grunnskole API endpoint" do
        VCR.use_cassette("nsr/skolekategori_1_grunnskole") do
          # Create a test double for filter_schools that just captures the arguments
          schools_passed_to_filter = []

          # Spy on the filter_schools method
          allow(service).to receive(:select_relevant_schools_from_list) do |schools|
            # Just capture the schools for our test
            schools_passed_to_filter = schools
            # Return an empty array as we don't need the actual filtering for this test
            []
          end

          # Set up spies for the HTTP calls
          allow(HTTP).to receive(:get).and_return(
            instance_double(HTTP::Response, status: success_response, body: empty_body)
          )
          # Let only the specific endpoint use the real implementation
          allow(HTTP).to receive(:get).with("#{nsr_uri_skoler_per_skolekategori}/1").and_call_original

          service.call

          # Verify endpoint calls
          expect(HTTP).to have_received(:get).with("#{nsr_uri_skoler_per_skolekategori}/1")

          # Check that at least some reasonable number of schools was fetched
          expect(
            schools_passed_to_filter.size
          ).to be >= 10,
               "Expected to fetch at least 10 schools from Grunnskole API, but got #{schools_passed_to_filter.size}"

          # Verify the first school has the expected structure
          expect(schools_passed_to_filter.first).to include("Navn", "ErAktiv")
        end
      end

      it "fetches at least 10 schools from Videregående skole API endpoint" do
        VCR.use_cassette("nsr/skolekategori_2_videregaende") do
          # Create a test double for filter_schools that just captures the arguments
          schools_passed_to_filter = []

          # Spy on the filter_schools method
          allow(service).to receive(:select_relevant_schools_from_list) do |schools|
            # Just capture the schools for our test
            schools_passed_to_filter = schools
            # Return an empty array as we don't need the actual filtering for this test
            []
          end

          # Set up spies for the HTTP calls
          allow(HTTP).to receive(:get).and_return(
            instance_double(HTTP::Response, status: success_response, body: empty_body)
          )
          # Let only the specific endpoint use the real implementation
          allow(HTTP).to receive(:get).with("#{nsr_uri_skoler_per_skolekategori}/2").and_call_original

          service.call

          # Verify endpoint calls
          expect(HTTP).to have_received(:get).with("#{nsr_uri_skoler_per_skolekategori}/2")

          # Check that at least some reasonable number of schools was fetched
          expect(
            schools_passed_to_filter.size
          ).to be >= 10,
               "Expected to fetch at least 10 schools from Videregående API, but got #{schools_passed_to_filter.size}"

          # Verify the schools have the expected structure
          expect(schools_passed_to_filter.first).to include("Navn", "ErAktiv")
        end
      end

      it "fetches at least 10 schools from Folkehøyskole API endpoint" do
        VCR.use_cassette("nsr/skolekategori_11_folkehoyskole") do
          # Create a test double for filter_schools that just captures the arguments
          schools_passed_to_filter = []
          service.method(:select_relevant_schools_from_list)

          # Spy on the filter_schools method
          allow(service).to receive(:select_relevant_schools_from_list) do |schools|
            # Just capture the schools for our test
            schools_passed_to_filter = schools
            # Return an empty array as we don't need the actual filtering for this test
            []
          end

          # Set up spies for the HTTP calls
          allow(HTTP).to receive(:get).and_return(
            instance_double(HTTP::Response, status: success_response, body: empty_body)
          )
          # Let only the specific endpoint use the real implementation
          allow(HTTP).to receive(:get).with("#{nsr_uri_skoler_per_skolekategori}/11").and_call_original

          service.call

          # Verify endpoint calls
          expect(HTTP).to have_received(:get).with("#{nsr_uri_skoler_per_skolekategori}/11")

          # Check that at least some reasonable number of schools was fetched
          expect(
            schools_passed_to_filter.size
          ).to be >= 10,
               "Expected to fetch at least 10 schools from Folkehøyskole API, but got #{schools_passed_to_filter.size}"

          # Verify the schools have the expected structure
          expect(schools_passed_to_filter.first).to include("Navn", "ErAktiv")
        end
      end
    end
  end

  describe "#fetch_school_details" do
    let(:service) { described_class.new }
    let(:org_number) { "975279154" } # Use a real org number from the VCR cassette
    let(:date_changed_at_from_nsr) { "2025-03-21T08:38:18.143+01:00" }
    let(:later_date_changed_at_from_nsr) { "2025-04-21T08:38:18.143+01:00" }

    describe "caching behavior integration tests", :vcr do
      it "caches school details and uses cache on subsequent requests" do
        # Use the real Rails cache for this test
        Rails.cache.clear

        # Set up HTTP tracking
        allow(HTTP).to receive(:get).and_call_original
        http_url = "#{SyncingData::FromNsr::NSR_BASE_URL}/enhet/#{org_number}"

        # First call should fetch data and cache it
        VCR.use_cassette("nsr/enhet/#{org_number}", allow_playback_repeats: true) do
          first_result = service.send(:details_about_school, org_number:, date_changed_at_from_nsr:)
          expect(first_result).to be_present
          expect(first_result["Organisasjonsnummer"]).to eq(org_number)

          # Second call should use the cache
          second_result = service.send(:details_about_school, org_number:, date_changed_at_from_nsr:)
          expect(second_result).to eq(first_result)

          # Verify HTTP was called only once
          expect(HTTP).to have_received(:get).with(http_url).once
        end
      end

      it "refreshes cache when DatoEndret is newer" do
        # Use the real Rails cache for this test
        Rails.cache.clear

        # First call to populate cache
        VCR.use_cassette("nsr/enhet/#{org_number}", allow_playback_repeats: true) do
          # Set up cache manually to ensure date_changed_at_from_nsr matching
          cache_data = {
            data: { "Organisasjonsnummer" => org_number, "DatoEndret" => date_changed_at_from_nsr },
            date_changed_at_from_nsr: date_changed_at_from_nsr,
            cached_at: Time.current.iso8601
          }
          Rails.cache.write("nsr:school:#{org_number}", cache_data)

          # Set up HTTP tracking
          allow(HTTP).to receive(:get).and_call_original
          http_url = "#{SyncingData::FromNsr::NSR_BASE_URL}/enhet/#{org_number}"

          # Call with newer date
          service.send(:details_about_school, org_number:, date_changed_at_from_nsr: later_date_changed_at_from_nsr)

          # Verify HTTP was called
          expect(HTTP).to have_received(:get).with(http_url).once
        end
      end
    end

    context "when the API call is successful", :vcr do
      it "fetches detailed information for a school" do
        VCR.use_cassette("nsr/enhet/#{org_number}") do
          school_details = service.send(:details_about_school, org_number:, date_changed_at_from_nsr:)

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
        allow(Rails.logger).to receive(:error)
      end

      it "raises an error and logs it" do
        # Allow the cache methods to maintain test isolation
        allow(service).to receive(:cache_still_fresh?).and_return(false)

        expect do
          service.send(:details_about_school, org_number: org_number,
                                              date_changed_at_from_nsr: date_changed_at_from_nsr)
        end.to raise_error(/API Error/)

        # The error is logged and we don't care how many times, just that it happened
        expect(Rails.logger).to have_received(:error).with(/Failed to fetch school details/).at_least(:once)
      end
    end
  end

  describe "#fetch_all_school_details" do
    let(:service) { described_class.new }
    let(:schools) do
      [
        { "Organisasjonsnummer" => "975279154", "Navn" => "Aa skole", "DatoEndret" => "2025-03-21T08:38:18.143+01:00" },
        { "Organisasjonsnummer" => "995922770", "Navn" => "Aalesund International School Sti",
          "DatoEndret" => "2025-03-21T08:38:18.143+01:00" },
        { "Organisasjonsnummer" => "975283046", "Navn" => "Abel skole",
          "DatoEndret" => "2025-03-21T08:38:18.143+01:00" }
      ]
    end

    it "fetches details for all schools" do
      VCR.use_cassette("nsr/enhet/multiple_schools", record: :new_episodes) do
        result = service.send(:fetch_details_about_all_schools, schools)
        expect(result).to be_a(Array)
        expect(result.map { |s| s["Organisasjonsnummer"] })
          .to contain_exactly("975279154", "995922770", "975283046")
      end
    end

    it "skips schools with no organization number" do
      schools_with_missing_org = schools + [{ "Navn" => "Fiktiv skole uten organisasjonsnummer" }]

      allow(service).to receive(:details_about_school).and_return({ "data" => "test" })

      result = service.send(:fetch_details_about_all_schools, schools_with_missing_org)

      # Should only call fetch_school_details for schools with org numbers
      expect(service).to have_received(:details_about_school).exactly(schools.size).times
      expect(result.size).to eq(schools.size)
    end

    it "continues processing after errors with individual schools" do
      allow(Rails.logger).to receive(:error)

      # First and third schools succeed, second fails
      allow(service).to receive(:details_about_school)
        .with(org_number: schools[0]["Organisasjonsnummer"], date_changed_at_from_nsr: schools[0]["DatoEndret"])
        .and_return({ "data" => "test1" })

      allow(service).to receive(:details_about_school)
        .with(org_number: schools[1]["Organisasjonsnummer"], date_changed_at_from_nsr: schools[1]["DatoEndret"])
        .and_raise("API Error")

      allow(service).to receive(:details_about_school)
        .with(org_number: schools[2]["Organisasjonsnummer"], date_changed_at_from_nsr: schools[2]["DatoEndret"])
        .and_return({ "data" => "test3" })

      result = service.send(:fetch_details_about_all_schools, schools)

      # Should have logged errors
      expect(Rails.logger).to have_received(:error).with(/Error fetching details for school/)
      expect(Rails.logger).to have_received(:error).with(/Failed to fetch details for 1 schools/)

      # Should still have processsed the other schools
      expect(result.size).to eq(2)
    end
  end

  context "when processing several schools" do
    let(:service) { described_class.new }
    let(:schools_to_process) do
      [
        { "Organisasjonsnummer" => "975279154", "Navn" => "Aa skole", "DatoEndret" => "2025-03-21T08:38:18.143+01:00" },
        { "Organisasjonsnummer" => "995922770", "Navn" => "Aalesund International School Sti",
          "DatoEndret" => "2025-03-21T08:38:18.143+01:00" },
        { "Organisasjonsnummer" => "975283046", "Navn" => "Abel skole",
          "DatoEndret" => "2025-03-21T08:38:18.143+01:00" }
      ]
    end
    let!(:schools_with_details) do
      VCR.use_cassette("nsr/enhet/multiple_schools", record: :new_episodes) do
        service.send(:fetch_details_about_all_schools, schools_to_process)
      end
    end

    it "processes new schools into Spaces" do
      spaces = service.send(:process_schools_and_save_space_data, schools_with_details)
      expect(spaces.size).to eq(3)
      expect(spaces.all?(Space)).to be true
    end

    it "processes new schools into valid spaces" do
      spaces = service.send(:process_schools_and_save_space_data, schools_with_details)
      expect(spaces.all?(&:valid?)).to be true
    end
  end

  context "when processing a school we already have" do
    let(:service) { described_class.new }
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
                        organization_number: "975283046",
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
        service.send(:fetch_details_about_all_schools, [{ "Organisasjonsnummer" => "975283046" }]).first
      end
    end
    let!(:synced_space_for_abel) do
      VCR.use_cassette("nsr/enhet/processing_school_abel") do
        spaces = service.send(:process_schools_and_save_space_data, [school_details])
        spaces.first
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

    it "preserves old space_group information in the new space group" do
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
    let(:service) { described_class.new }
    let(:public_school_details) do
      VCR.use_cassette("nsr/enhet/public_school_abel") do
        service.send(:fetch_details_about_all_schools, [{ "Organisasjonsnummer" => "975283046" }]).first
      end
    end
    let!(:space) do
      VCR.use_cassette("nsr/enhet/processing_school_abel") do
        spaces = service.send(:process_schools_and_save_space_data, [public_school_details])

        spaces.first
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
      expect(space.organization_number).to eq("975283046")
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

  context "when a school we already have no longer is active" do
    # TODO: This test is not implemented yet
    # rubocop:disable RSpec/RepeatedExample
    let(:service) { described_class.new }

    it "marks the space as closed" do
      skip "Not implemented"
    end

    it "only marks the space as closed, if it hasn't been re-opened before" do
      skip "Not implemented"
    end
    # rubocop:enable RSpec/RepeatedExample
  end
end

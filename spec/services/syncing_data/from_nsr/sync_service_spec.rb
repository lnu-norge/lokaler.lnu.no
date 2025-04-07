# frozen_string_literal: true

require "rails_helper"
require "webmock/rspec"

RSpec.describe SyncingData::FromNsr::SyncService do
  let(:nsr_base_uri) { "https://data-nsr.udir.no/v4/" }
  let(:nsr_uri_skoler_per_skolekategori) { "#{nsr_base_uri}enheter/skolekategori" }
  let(:nsr_uri_enhet) { "#{nsr_base_uri}enhet" }

  describe "#filter_schools" do
    let(:service) { described_class.new }
    let(:inactive_school) { { "ErAktiv" => false, "Organisasjonsnummer" => "123456789" } }
    let(:active_school) { { "ErAktiv" => true, "Organisasjonsnummer" => "987654321" } }
    let(:inactive_school_no_orgnr) { { "ErAktiv" => false } }
    let(:inactive_school_existing) { { "ErAktiv" => false, "Organisasjonsnummer" => "555555555" } }

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

    it "processes new schools into valid Spaces" do
      spaces = service.send(:process_list_of_schools, schools_with_details)
      expect(spaces.size).to eq(3)
      expect(spaces.all? { |space| space.is_a?(Space) && space.valid? }).to be true
    end
  end

  context "when processing Abel, a public school" do
    let(:service) { described_class.new }
    let(:public_school_details) do
      VCR.use_cassette("nsr/enhet/public_school_abel") do
        service.send(:fetch_details_about_all_schools, [{ "Organisasjonsnummer" => "975283046" }]).first
      end
    end

    it "sets the right organization number" do
      spaces = service.send(:process_list_of_schools, [public_school_details])
      expect(spaces.first.organization_number).to eq("975283046")
    end

    it "sets the right space type" do
      expect(space.space_types).to include(SpaceType.find_by(type_name: "Grunnskole"))
    end

    it "sets the right space group" do
      expect(space.space_group).to be_present
      expect(space.space_group.title).to include("Gjerstad kommune")
    end

    it "sets the right title" do
      spaces = service.send(:process_list_of_schools, [public_school_details])
      expect(spaces.first.title).to eq("Abel skole")
    end

    it "sets the right address" do
      spaces = service.send(:process_list_of_schools, [public_school_details])
      expect(spaces.first.address).to eq("Skjervegen 1")
    end
  end
end

# frozen_string_literal: true

require "rails_helper"
require "webmock/rspec"

RSpec.describe SyncingData::FromNsr::SyncService do
  let(:nsr_base_uri) { "https://data-nsr.udir.no/v4/" }
  let(:nsr_uri_skoler_per_skolekategori) { "#{nsr_base_uri}enheter/skolekategori" }
  let(:nsr_uri_enhet) { "#{nsr_base_uri}enhet" }

  describe "#filter_schools" do
    let(:service) { described_class.new }
    let(:inactive_school) { { "ErAktiv" => false, "OrgNr" => "123456789" } }
    let(:active_school) { { "ErAktiv" => true, "OrgNr" => "987654321" } }
    let(:inactive_school_no_orgnr) { { "ErAktiv" => false } }
    let(:inactive_school_existing) { { "ErAktiv" => false, "OrgNr" => "555555555" } }

    before do
      # Create a space with organization_number matching inactive_school_existing
      Fabricate(:space, organization_number: "555555555")
    end

    it "keeps active schools regardless of organization number" do
      schools = [active_school]
      result = service.send(:filter_schools, schools)
      expect(result).to eq([active_school])
    end

    it "filters out inactive schools with no matching spaces" do
      schools = [inactive_school]
      result = service.send(:filter_schools, schools)
      expect(result).to be_empty
    end

    it "keeps inactive schools with organization numbers that already exist in spaces" do
      schools = [inactive_school_existing]
      result = service.send(:filter_schools, schools)
      expect(result).to eq([inactive_school_existing])
    end

    it "filters out inactive schools with no organization number" do
      schools = [inactive_school_no_orgnr]
      result = service.send(:filter_schools, schools)
      expect(result).to be_empty
    end

    it "correctly handles a mix of schools" do
      schools = [active_school, inactive_school, inactive_school_existing, inactive_school_no_orgnr]
      result = service.send(:filter_schools, schools)
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
          allow(service).to receive(:filter_schools) do |schools|
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
          allow(service).to receive(:filter_schools) do |schools|
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
          service.method(:filter_schools)

          # Spy on the filter_schools method
          allow(service).to receive(:filter_schools) do |schools|
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

    context "when the API call is successful", :vcr do
      it "fetches detailed information for a school" do
        VCR.use_cassette("nsr/enhet/#{org_number}") do
          school_details = service.send(:fetch_school_details, org_number)

          # Verify the response contains expected data
          expect(school_details).to be_a(Hash)
          expect(school_details["Organisasjonsnummer"]).to eq(org_number)
          expect(school_details).to include("Navn", "Beliggenhetsadresse", "Kommune")
        end
      end
    end

    context "when the API call fails" do
      let(:error_response) do
        instance_double(HTTP::Response::Status, success?: false, code: 404)
      end

      let(:error_body) do
        instance_double(HTTP::Response::Body, to_s: "Not Found")
      end

      before do
        allow(HTTP).to receive(:get).with("#{nsr_uri_enhet}/#{org_number}").and_return(
          instance_double(HTTP::Response, status: error_response, body: error_body)
        )
      end

      it "returns nil and logs an error" do
        allow(Rails.logger).to receive(:error)

        result = service.send(:fetch_school_details, org_number)

        expect(result).to be_nil
        expect(Rails.logger).to have_received(:error).with(/Failed to fetch school details/)
      end
    end
  end

  describe "#fetch_all_school_details" do
    let(:service) { described_class.new }
    let(:schools) do
      [
        { "OrgNr" => "975279154", "Navn" => "Aa skole" },
        { "OrgNr" => "995922770", "Navn" => "Aalesund International School Sti" },
        { "OrgNr" => "975283046", "Navn" => "Abel skole" }
      ]
    end

    it "fetches details for all schools" do
      # Mock the fetch_school_details method
      allow(service).to receive(:fetch_school_details).and_return({ "data" => "test" })

      result = service.send(:fetch_all_school_details, schools)

      # Should call fetch_school_details once per school
      expect(service).to have_received(:fetch_school_details).exactly(schools.size).times
      # Should return a hash with org numbers as keys
      expect(result.keys).to contain_exactly("975279154", "995922770", "975283046")
    end

    it "skips schools with no organization number" do
      schools_with_missing_org = schools + [{ "Navn" => "Fiktiv skole uten organisasjonsnummer" }]

      allow(service).to receive(:fetch_school_details).and_return({ "data" => "test" })

      result = service.send(:fetch_all_school_details, schools_with_missing_org)

      # Should only call fetch_school_details for schools with org numbers
      expect(service).to have_received(:fetch_school_details).exactly(schools.size).times
      expect(result.size).to eq(schools.size)
    end
  end
end

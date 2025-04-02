# frozen_string_literal: true

require "rails_helper"
require "webmock/rspec"

RSpec.describe SyncingData::FromNsr::SyncService do
  let(:nsr_base_uri) { "https://data-nsr.udir.no/v4/" }
  let(:nsr_uri_skoler_per_skolekategori) { "#{nsr_base_uri}enheter/skolekategori" }

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
end

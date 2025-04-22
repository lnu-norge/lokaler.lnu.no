# frozen_string_literal: true

require "rails_helper"
require "webmock/rspec"

RSpec.describe SyncingData::FromNsr::RunSyncService do
  let(:nsr_base_uri) { "https://data-nsr.udir.no/v4/" }
  let(:nsr_uri_skoler_per_skolekategori) { "#{nsr_base_uri}enheter/skolekategori" }
  let(:service) { described_class.new }
  let(:logger_with_tags) { service.send(:logger) }

  before do
    # Set up the needed SpaceTypes
    Fabricate(:space_type, type_name: "Grunnskole")
    Fabricate(:space_type, type_name: "VGS")
    Fabricate(:space_type, type_name: "Folkehøgskole")
  end

  describe "#filter_schools" do
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
      Admin::SyncStatus
        .for(id_from_source: space_for_already_synced_school.organization_number, source: "nsr")
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

    it "creates and enqueues jobs in bulk for schools that need updating" do
      # Mock the school filtering to return a known set
      schools = [
        { "Organisasjonsnummer" => "123456789", "DatoEndret" => "2025-03-21T08:38:18.143+01:00" },
        { "Organisasjonsnummer" => "987654321", "DatoEndret" => "2025-03-21T08:38:18.143+01:00" }
      ]

      allow(service).to receive_messages(fetch_combined_list_of_schools: [], select_relevant_schools_from_list: schools)

      # Set up spies for job creation and bulk enqueuing
      job1 = instance_double(SyncNsrSchoolJob)
      job2 = instance_double(SyncNsrSchoolJob)

      allow(SyncNsrSchoolJob).to receive(:new)
        .with(org_number: "123456789", date_changed_at_from_nsr: "2025-03-21T08:38:18.143+01:00")
        .and_return(job1)
      allow(SyncNsrSchoolJob).to receive(:new)
        .with(org_number: "987654321", date_changed_at_from_nsr: "2025-03-21T08:38:18.143+01:00")
        .and_return(job2)

      allow(ActiveJob).to receive(:perform_all_later)

      service.call

      # Verify jobs were created with correct parameters
      expect(SyncNsrSchoolJob).to have_received(:new)
        .with(org_number: "123456789", date_changed_at_from_nsr: "2025-03-21T08:38:18.143+01:00")
      expect(SyncNsrSchoolJob).to have_received(:new)
        .with(org_number: "987654321", date_changed_at_from_nsr: "2025-03-21T08:38:18.143+01:00")

      # Verify jobs were enqueued in bulk
      expect(ActiveJob).to have_received(:perform_all_later).with(contain_exactly(job1, job2))
    end

    it "skips schools with blank organization number or date changed" do
      schools = [
        { "Organisasjonsnummer" => "", "DatoEndret" => "2025-03-21T08:38:18.143+01:00" },
        { "Organisasjonsnummer" => "987654321", "DatoEndret" => nil },
        { "Organisasjonsnummer" => "123456789", "DatoEndret" => "2025-03-21T08:38:18.143+01:00" }
      ]

      allow(service).to receive_messages(fetch_combined_list_of_schools: [], select_relevant_schools_from_list: schools)

      # Set up spies for job creation and bulk enqueuing
      job = instance_double(SyncNsrSchoolJob)
      allow(SyncNsrSchoolJob).to receive(:new).and_return(nil)
      allow(SyncNsrSchoolJob).to receive(:new)
        .with(org_number: "123456789", date_changed_at_from_nsr: "2025-03-21T08:38:18.143+01:00")
        .and_return(job)

      allow(ActiveJob).to receive(:perform_all_later)

      service.call

      # Verify only the valid job was created
      expect(SyncNsrSchoolJob).to have_received(:new)
        .with(org_number: "123456789", date_changed_at_from_nsr: "2025-03-21T08:38:18.143+01:00")
        .once

      # Verify jobs with blank org number or date were not created
      expect(SyncNsrSchoolJob).not_to have_received(:new)
        .with(org_number: "", date_changed_at_from_nsr: "2025-03-21T08:38:18.143+01:00")
      expect(SyncNsrSchoolJob).not_to have_received(:new)
        .with(org_number: "987654321", date_changed_at_from_nsr: nil)

      # Verify jobs were enqueued in bulk with just the valid job
      expect(ActiveJob).to have_received(:perform_all_later).with([job])
    end
  end
end

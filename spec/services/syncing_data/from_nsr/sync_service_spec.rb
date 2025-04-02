# frozen_string_literal: true

require "rails_helper"
require "webmock/rspec"

RSpec.describe SyncingData::FromNsr::SyncService do
  let(:nsr_base_uri) { "https://data-nsr.udir.no/v4/" }
  let(:nsr_uri_skoler_per_skolekategori) { "#{nsr_base_uri}enheter/skolekategori" }

  describe "#call" do
    let(:service) { described_class.new }

    context "with real API responses", :vcr do
      let(:success_response) do
        instance_double(HTTP::Response::Status, success?: true)
      end

      let(:empty_body) do
        instance_double(HTTP::Response::Body, to_s: "[]")
      end

      it "fetches data from Grunnskole API endpoint" do
        VCR.use_cassette("nsr/skolekategori_1_grunnskole") do
          # Set up spies
          allow(HTTP).to receive(:get).and_return(
            instance_double(HTTP::Response, status: success_response, body: empty_body)
          )
          # Let only the specific endpoint use the real implementation
          allow(HTTP).to receive(:get).with("#{nsr_uri_skoler_per_skolekategori}/1").and_call_original

          service.call

          # Verify endpoint calls
          expect(HTTP).to have_received(:get).with("#{nsr_uri_skoler_per_skolekategori}/1")
          expect(HTTP).to have_received(:get).with("#{nsr_uri_skoler_per_skolekategori}/2")
          expect(HTTP).to have_received(:get).with("#{nsr_uri_skoler_per_skolekategori}/11")
        end
      end

      it "fetches data from Videregående skole API endpoint" do
        VCR.use_cassette("nsr/skolekategori_2_videregaende") do
          # Set up spies
          allow(HTTP).to receive(:get).and_return(
            instance_double(HTTP::Response, status: success_response, body: empty_body)
          )
          # Let only the specific endpoint use the real implementation
          allow(HTTP).to receive(:get).with("#{nsr_uri_skoler_per_skolekategori}/2").and_call_original

          service.call

          # Verify endpoint calls
          expect(HTTP).to have_received(:get).with("#{nsr_uri_skoler_per_skolekategori}/1")
          expect(HTTP).to have_received(:get).with("#{nsr_uri_skoler_per_skolekategori}/2")
          expect(HTTP).to have_received(:get).with("#{nsr_uri_skoler_per_skolekategori}/11")
        end
      end

      it "fetches data from Folkehøyskole API endpoint" do
        VCR.use_cassette("nsr/skolekategori_11_folkehoyskole") do
          # Set up spies
          allow(HTTP).to receive(:get).and_return(
            instance_double(HTTP::Response, status: success_response, body: empty_body)
          )
          # Let only the specific endpoint use the real implementation
          allow(HTTP).to receive(:get).with("#{nsr_uri_skoler_per_skolekategori}/11").and_call_original

          service.call

          # Verify endpoint calls
          expect(HTTP).to have_received(:get).with("#{nsr_uri_skoler_per_skolekategori}/1")
          expect(HTTP).to have_received(:get).with("#{nsr_uri_skoler_per_skolekategori}/2")
          expect(HTTP).to have_received(:get).with("#{nsr_uri_skoler_per_skolekategori}/11")
        end
      end
    end
  end
end

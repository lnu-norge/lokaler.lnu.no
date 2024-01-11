# frozen_string_literal: true

RSpec.shared_context "with VCR for http calls" do
  around do |test|
    VCR.use_cassette test.full_description do
      test.run
    end
  end
end

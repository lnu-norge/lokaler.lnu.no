# frozen_string_literal: true

require "uri"

module ParseUrlHelper
  def parse_url
    uri = URI.parse(url)
    self.url = "http://#{uri}" unless uri.scheme
  end
end

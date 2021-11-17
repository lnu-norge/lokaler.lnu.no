# frozen_string_literal: true

module ParseUrlHelper
  def parse_url
    uri = Addressable::URI.parse(url)
    self.url = "http://#{url}" unless uri.blank? || uri.scheme || url.blank?
  end
end

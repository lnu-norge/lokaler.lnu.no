# frozen_string_literal: true

class UrlValidationService
  include ActiveModel::Validations

  attr_accessor :url

  validates :url, url: { allow_blank: true, public_suffix: true }

  def initialize(url)
    @url = url
  end

  def valid_url?
    valid?
  end
end

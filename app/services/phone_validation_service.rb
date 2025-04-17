# frozen_string_literal: true

class PhoneValidationService
  include ActiveModel::Validations

  attr_accessor :phone

  validates :phone, phone: { allow_blank: true }

  def initialize(phone)
    @phone = phone
  end

  def valid_phone?
    valid?
  end
end

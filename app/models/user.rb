# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  include Gravtastic
  gravtastic default: "retro"

  has_many :reviews, dependent: :restrict_with_exception
  has_and_belongs_to_many :organizations

  def name
    return first_name unless last_name&.present?
    return last_name unless first_name&.present?

    "#{first_name} #{last_name[0]&.upcase}."
  end
end

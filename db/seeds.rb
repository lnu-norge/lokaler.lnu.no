# frozen_string_literal: true

# Seed files contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
#
# You will find seed files for each environment in the db/seeds folder
# They are loaded conditionally on the development environment here.
#
# Seeds that are common for all environment are in the "seeds/common.rb" file.

# Load seeds based on environment::
ActiveRecord::Base.transaction do
  possible_seed_file = ENV["SEED_FILE"] || Rails.env
  file = Rails.root.join("db", "seeds", "#{possible_seed_file}.rb")
  next unless File.exist?(file)

  # rubocop:disable  Rails/Output
  puts "- - Seeding data from file: #{possible_seed_file}"
  # rubocop:enable  Rails/Output
  require file
end

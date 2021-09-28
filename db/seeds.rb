# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Seeds are split into different files, based on environment:
ActiveRecord::Base.transaction do
  ['common', Rails.env].each do |seedfile|
    seed_file = Rails.root.join "/db/seeds/#{seedfile}.rb"
    next unless File.exist?(seed_file)

    # rubocop:disable  Rails/Output
    puts "- - Seeding data from file: #{seedfile}"
    # rubocop:enable  Rails/Output
    require seed_file
  end
end

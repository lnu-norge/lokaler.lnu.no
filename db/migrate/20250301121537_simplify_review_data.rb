# frozen_string_literal: true

class SimplifyReviewData < ActiveRecord::Migration[7.2]
  include ActionView::Helpers::NumberHelper

  def up
    # First move the old data to be a string in the comment field.
    Review.find_each do |review|
      old_data_as_text = old_columns_to_text(review)
      return if old_data_as_text.blank?

      new_comment = review.comment + "\n\n" + old_columns_to_text(review)

      review.update!(comment: new_comment)
    end

    remove_column :reviews, :how_much
    remove_column :reviews, :how_much_custom
    remove_column :reviews, :how_long
    remove_column :reviews, :how_long_custom
    remove_column :reviews, :price
    remove_column :reviews, :type_of_contact
  end

  def down
    add_column :reviews, :how_much, :integer
    add_column :reviews, :how_much_custom, :string
    add_column :reviews, :how_long, :integer
    add_column :reviews, :how_long_custom, :string
    add_column :reviews, :price, :string
    add_column :reviews, :type_of_contact, :integer
  end

  private

  def old_columns_to_text (review)
    [
      type_of_contact_to_text(review),
      how_much_to_text(review),
      how_long_to_text(review),
      price_to_text(review),
    ].compact.join(" ")
  end

  def price_to_text (review)
    return nil if review.price.blank?

    "Betalte #{number_with_delimiter(review.price)} kr."
  end

  def how_much_to_text (review)
    return nil if review.how_much.blank?

    case review.how_much
    when 0 # custom_how_much
      "Brukte: #{review.how_much_custom}."
    when 1 #w whole_space
      "Vi brukte hele lokalet."
    when 2 # one_room
      "Vi brukte ett rom."
    else
      nil
    end
  end

  def how_long_to_text (review)
    return nil if review.how_long.blank?

    case review.how_long
    when 0 # custom_how_long
      "Var der: #{review.how_long_custom}"
    when 1 #w one_weekend
      "Var der en helg."
    when 2 # one_evening
      "Var der en kveld."
    else
      nil
    end
  end

  def type_of_contact_to_text (review)
    return nil if review.type_of_contact.blank?

    case review.type_of_contact
    when 0 # only_contacted
      "Ikke brukt lokalet, bare tatt kontakt."
    when 1 # not_allowed_to_use
      "Fikk ikke lov til å bruke lokalet."
    else # been_there
      nil
    end
  end
end

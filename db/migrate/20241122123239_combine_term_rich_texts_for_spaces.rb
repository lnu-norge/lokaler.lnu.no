# frozen_string_literal: true

class CombineTermRichTextsForSpaces < ActiveRecord::Migration[7.2]

  def up
    ActiveRecord::Base.transaction do
      # Note 22. november, 2024:
      # This intentionally does not delete the old texts, to make sure the action is reversible if we have done something wrong
      # There are not many old texts, so it should be fine to leave them there.
      # If years have passed, feel free to delete the old data.

      p "Combining terms and pricing for spaces and space groups..."
      # Combine who_can_use, pricing, and terms into one rich text field
      Space.find_each.with_index do |space, index|
        print "\rProcessing space #{index} / #{Space.count}          "
        combine_terms_and_pricing_for(space)
      end
      SpaceGroup.find_each.with_index do |space_group, index|
        print "\rProcessing space group #{index} / #{SpaceGroup.count}         "
        combine_terms_and_pricing_for(space_group)
      end
      print "\rProcessed all spaces and space groups\n"
    end
  end

  private

  def html_with_attachments_for(field, record:, record_type:)
    ActionText::RichText
      .find_by(record_type:, record_id: record.id, name: field)
      &.body
      &.to_trix_html
  end

  def combine_terms_and_pricing_for(record)
    record_type = record.class.name

    who_can_use = html_with_attachments_for('who_can_use', record:, record_type:)
    pricing = html_with_attachments_for('pricing', record:, record_type:)
    terms = html_with_attachments_for('terms', record:, record_type:)
    terms_and_pricing = html_with_attachments_for('terms_and_pricing', record:, record_type:)

    # If there is user data here, do not overwrite it
    return if terms_and_pricing.present?

    combined_terms_and_pricing = String.new
    combined_terms_and_pricing << "<h3>Hvem får bruke lokalet?</h3>" if who_can_use.present?
    combined_terms_and_pricing << who_can_use if who_can_use.present?
    combined_terms_and_pricing << "<h3>Pris</h3>" if combined_terms_and_pricing.present? && pricing.present?
    combined_terms_and_pricing << pricing if pricing.present?
    combined_terms_and_pricing << "<h3>Andre vilkår</h3>" if combined_terms_and_pricing.present? && terms.present?
    combined_terms_and_pricing << terms if terms.present?

    ActionText::RichText.create!(
      record_type:,
      record_id: record.id,
      name: 'terms_and_pricing',
      body: ActionText::Content.new(combined_terms_and_pricing)
    )
  end
end

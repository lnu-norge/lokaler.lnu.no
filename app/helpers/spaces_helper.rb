# frozen_string_literal: true

module SpacesHelper
  def edit_field(partial, form)
    render partial: "spaces/edit/#{partial}", locals: { form: form }
  end

  def inline_editable(field, title = { h2: nil }, &block)
    render partial: 'spaces/editable_inline', locals: {
      field: field,
      title_tag: title.first[0],
      title_text: title.first[1],
      block: block
    }
  end
end

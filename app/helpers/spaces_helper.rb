# frozen_string_literal: true

module SpacesHelper
  def edit_field(partial, form)
    render partial: "spaces/edit/#{partial}", locals: { form: form }
  end

  def editable_inline(field, &block)
    render partial: 'spaces/editable_inline', locals: {
      field: field,
      block: block
    }
  end
end

# frozen_string_literal: true

ActiveSupport.on_load(:action_text_rich_text) do
  ActionText::RichText.class_eval do
    has_paper_trail
  end
end

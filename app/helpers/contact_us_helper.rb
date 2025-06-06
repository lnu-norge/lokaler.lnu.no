# frozen_string_literal: true

module ContactUsHelper
  def mailto_contact_us_path
    "mailto:#{email}?subject=#{ERB::Util.url_encode(subject)}&body=#{ERB::Util.url_encode(body)}"
  end

  private

  def email
    "lokaler@lnu.no"
  end

  def subject
    "Tilbakemedling om LNU Lokaler"
  end

  def body
    "Hei!

Kjapp tilbakemelding om LNU Lokaler:

#{signature}"
  end

  def signature
    return "" if current_user.blank?

    "Mvh
#{current_user.name}
#{current_user.organization_name.presence}"
  end
end

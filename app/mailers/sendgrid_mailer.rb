# frozen_string_literal: true

class SendgridMailer
  def self.send(to, template_id, **subsitutions)
    # Comment line under if you want to TEST emails from application
    return unless Rails.env.production?

    data = {
      personalizations: [
        {
          to: [
            {
              email: to
            }
          ],
          dynamic_template_data: subsitutions
        }
      ],
      from: {
        email: ENV.fetch("SENDGRID_FROM_EMAIL", nil)
      },
      template_id: template_id
    }
    sg = SendGrid::API.new(api_key: ENV.fetch("SENDGRID_API_KEY", nil))
    response = sg.client.mail._("send").post(request_body: data)

    response.status_code
  end
end

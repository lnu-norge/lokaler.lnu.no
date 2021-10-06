# frozen_string_literal: true

class SendgridMailer
  def self.send(to, template_id, **subsitutions)
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
        email: 'no-reply@lnu.no'
      },
      template_id: template_id
    }
    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    response = sg.client.mail._('send').post(request_body: data)

    response.status_code
  end
end

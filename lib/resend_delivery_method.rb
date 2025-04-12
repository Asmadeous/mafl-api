require "resend"

class ResendDeliveryMethod
  def initialize(settings)
    @api_key = settings[:api_key]
    Resend.api_key = @api_key
  end

  def deliver!(mail)
    Resend::Emails.send({
      from: "no-reply@yourdomain.com", # Replace with your verified Resend sender
      to: mail.to,
      subject: mail.subject,
      html: mail.body.encoded
    })
  end
end

class DeviseMailer < Devise::Mailer

  def confirmation_instructions(record, token, opts={})
  byebug
    mail = super
    mail.subject = "Confirmation instructions for ${record.first_name}"
    mail
  end

end

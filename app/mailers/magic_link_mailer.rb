class MagicLinkMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def magic_link(email, magic_link)
    @magic_link = magic_link
    mail(to: email, subject: 'Magic Link inside')
  end
end
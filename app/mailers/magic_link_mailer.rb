class MagicLinkMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def magic_link(email, magic_link)
    @magic_link = magic_link
    @url = "#{Rails.application.config.site_url }/magic_links/verify?signature=#{@magic_link.signature}"
    mail(to: email, subject: 'Magic Link inside')
  end
end
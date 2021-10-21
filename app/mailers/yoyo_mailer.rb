class YoyoMailer < ApplicationMailer
  default from: 'yo@yo.com'

  def yiyi
    mail(to: 'matt@matt.com', subject: 'Welcome to My Awesome Site')
  end
end
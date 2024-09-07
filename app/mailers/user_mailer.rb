class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.send_welcome_email.subject
  #
  def send_welcome_email(user)
    @user = user
    mail(to: user.email, subject: 'Welcome!')
  end
end

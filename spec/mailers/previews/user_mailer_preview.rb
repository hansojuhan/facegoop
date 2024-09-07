# Preview all emails at http://localhost:3000/rails/mailers/user_mailer_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer_mailer/send_welcome_email
  def send_welcome_email
    UserMailer.send_welcome_email
  end

end

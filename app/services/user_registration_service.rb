class UserRegistrationService
	def self.call(user)
    # If user was successfully created, send welcome email to user
		if user.persisted?
			UserMailer.send_welcome_email(user).deliver_later
		end
	end
end

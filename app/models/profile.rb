class Profile < ApplicationRecord
  # Each user has one profile
  belongs_to :user

  # Attach profile image
  has_one_attached :profile_image
end

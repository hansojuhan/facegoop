class UserFollower < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :followee, class_name: 'User'

  # Status enum
  enum status: { pending: 0, accepted: 1 }

  # Scopes to easily access follows by status
  scope :status_pending, -> { where(status: :pending) }
  scope :status_accepted, -> { where(status: :accepted) }

  # Prevent duplicate relationships
  validates :follower_id, uniqueness: { scope: :followee_id, message: "Relationship already exists" }
end

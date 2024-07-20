class Post < ApplicationRecord
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'

  # Likes
  has_many :likes, as: :record

  def liked_by?(user)
    likes.where(user: user).any?
  end

  # Create a second record if first one was found
  def like(user)
    likes.where(user: user).first_or_create
  end

  # Destroy all in order to take care of any duplicates
  def unlike(user)
    likes.where(user:user).destroy_all
  end
end

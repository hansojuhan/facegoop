class Post < ApplicationRecord
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'

  # Likes
  has_many :likes, as: :record, dependent: :destroy
  # Add this so that it would be possible to query all users who have liked a post
  has_many :liked_users, through: :likes, source: :user
  # Comments
  has_many :comments
  # Has an attached image
  has_one_attached :post_image

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

  # Fetch posts for users feed
  # Includes own posts + accepted followees posts
  def self.feed_posts(user)
    ids = user.accepted_followees.pluck(:id)
    ids << user.id
    Post.where(author_id: ids)
  end
end

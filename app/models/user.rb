class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Make user omniauthable
  devise :omniauthable, omniauth_providers: [:google_oauth2]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.full_name = auth.info.name
      user.avatar_url = auth.info.image

      # If you are using confirmable and the provider(s) you use validate emails, 
      # uncomment the line below to skip the confirmation emails.
      # user.skip_confirmation!
    end
  end

  # Has many posts as the 'author'
  has_many :posts, foreign_key: 'author_id'

  # Connect user with users they are following
  has_many :followed_users, foreign_key: 'follower_id', class_name: 'UserFollower'
  has_many :followees, through: :followed_users, source: :followee, dependent: :destroy

  # Connect user with those that are following them
  has_many :following_users, foreign_key: 'followee_id', class_name: 'UserFollower'
  has_many :followers, through: :following_users, source: :follower, dependent: :destroy

  # Likes
  has_many :likes, dependent: :destroy

  # Has many comments as the 'author'
  has_many :comments, foreign_key: 'author_id'

  # Methods to help get follows by status
  # Takes 'followees', the users whom current user is following,
  # and users the 'pending' scope to filter to only those with a 'pending' status
  def pending_followees
    followees.merge(UserFollower.status_pending)
  end

  def accepted_followees
    followees.merge(UserFollower.status_accepted)
  end

  def pending_followers
    followers.merge(UserFollower.status_pending)
  end

  def accepted_followers
    followers.merge(UserFollower.status_accepted)
  end

  # Has one profile
  has_one :profile, dependent: :destroy

  # Make sure profile is created one a user is created
  after_create :create_profile

  private

  def create_profile
    Profile.create(user: self)
  end
end

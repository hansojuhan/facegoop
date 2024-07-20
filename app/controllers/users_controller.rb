class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    # All users except current user
    @users = User.excluding(current_user)
  end

  # GET followers_users_path
  def followers
    @followers = current_user.accepted_followers

    # Pending requests
    @pending_followers = current_user.pending_followers
  end

  # GET following_users_path
  def following
    @following_users = current_user.accepted_followees
  end
end

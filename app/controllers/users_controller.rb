class UsersController < ApplicationController
  def index
    # All users except current user
    @users = User.excluding(current_user)

    # Pending requests
    @pending_followers = current_user.pending_followers
  end
end

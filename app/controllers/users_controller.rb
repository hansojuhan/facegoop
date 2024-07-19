class UsersController < ApplicationController
  def index
    # All users except current user
    @users = User.excluding(current_user)
  end
end

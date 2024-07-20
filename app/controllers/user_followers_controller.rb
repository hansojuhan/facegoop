class UserFollowersController < ApplicationController
  before_action :authenticate_user!

  # user_followers_path
  def create
    user = User.find(params[:followee_id])
  
    if current_user.followees << user
      flash[:success] = "Follow request sent!"
      redirect_to users_path
    else
      flash[:error] = "Something went wrong"
      render users_path, status: :unprocessable_entity
    end
  end

  # user_follower_path
  def destroy
    user = User.find(params[:id])

    if current_user.followees.delete(user)
      flash[:success] = 'Unfollowed user.'
      redirect_to users_path
    else
      flash[:error] = 'Something went wrong'
      redirect_to users_path, status: :unprocessable_entity
    end
  end

  # accept_user_follower_path
  def accept
    follower = User.find(params[:id])
    
    follow = UserFollower.find_by(follower: follower, followee: current_user)

    if follow.update(status: :accepted)
      flash[:success] = "Follow request accepted!"
      redirect_to users_path
    else
      flash[:error] = "Something went wrong"
      render users_path, status: :unprocessable_entity
    end
  end

  # user_follower_path	DELETE
  def remove
    follower = User.find(params[:id])
    
    follow = UserFollower.find_by(follower: follower, followee: current_user)

    if follow.destroy
      flash[:success] = "Follower removed"
      redirect_to followers_users_path
    else
      flash[:error] = "Something went wrong"
      render followers_users_path, status: :unprocessable_entity
    end
  end
end

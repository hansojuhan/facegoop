class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:user_id])
    @user_posts = @user.posts
  end

  def edit
  end

  def update
  end
end

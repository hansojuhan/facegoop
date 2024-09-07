class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:user_id])
    @user_posts = @user.posts
  end

  def edit
    @user = User.find(params[:user_id])
  end

  def update
    @user = User.find(params[:user_id])

    if @user.profile.update(profile_params)
      flash[:success] = "Object was successfully updated"
      redirect_to user_profile_path(@user)
    else
      flash[:error] = "Something went wrong"
      render 'edit', status: :unprocessable_entity
    end
  end

  private

  # Profile contains full name, bio and a profile image
  def profile_params
    params.require(:profile).permit(:full_name, :bio, :profile_image)
  end
end

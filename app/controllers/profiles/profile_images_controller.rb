class Profiles::ProfileImagesController < ApplicationController
  # To have dom_id for turbo stream response
  include ActionView::RecordIdentifier

  before_action :authenticate_user!
  before_action :set_user

  def destroy
    # Call purge later to purge as a background job
    @user.profile.profile_image.purge_later

    respond_to do |format|
      format.html { redirect_to edit_user_profile_path(@user) }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@user.profile, :profile_image)) }
    end
  end

  private

  # Find user from the URL parameter
  def set_user
    @user = User.find(params[:user_id])
  end
end

class Posts::LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post

  # Using just an update method, since this is basically a toggle
  def update
    if @post.liked_by?(current_user)
      @post.unlike(current_user)
    else
      @post.like(current_user)
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end

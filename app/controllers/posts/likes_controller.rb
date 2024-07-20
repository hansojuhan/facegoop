class Posts::LikesController < ApplicationController
  # This is to use dom_id in the turbo_stream
  # Other option is directy calling ActionView::RecordIdentifier.dom_id
  include ActionView::RecordIdentifier

  before_action :authenticate_user!
  before_action :set_post

  # Using just an update method, since this is basically a toggle
  def update
    if @post.liked_by?(current_user)
      @post.unlike(current_user)
    else
      @post.like(current_user)
    end

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace(dom_id(@post, :likes), partial: 'posts/likes', locals: { post: @post })
      }
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end

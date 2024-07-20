class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @comment = current_user.comments.new(comment_params)

    if @comment.save
      flash[:success] = "Comment successfully created"
      redirect_to post_path(params[:post_id])
    else
      flash[:error] = "Something went wrong: #{@comment.errors.full_messages}"
      render post_path(params[:post_id]), status: :unprocessable_entity
    end
  end
  
  private

  def comment_params
    params.require(:comment).permit(:content).merge(post_id: params[:post_id])
  end
end

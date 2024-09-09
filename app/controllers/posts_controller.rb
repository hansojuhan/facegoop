class PostsController < ApplicationController
  before_action :authenticate_user!

  def index
    @post = Post.new

    @posts = Post.feed_posts(current_user).order(created_at: :desc)
  end

  def new
    @post = Post.new
  end
  

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      flash[:success] = "Post successfully created"
      redirect_to @post
    else
      flash[:error] = "Something went wrong"
      render 'new'
    end
  end

  def show
    @post = Post.find(params[:id])
    @comment = current_user.comments.build(post: @post)
  end
  
  def edit
    @post = Post.find(params[:id])
  end
  
  def update
    @post = Post.find(params[:id])

    if @post.update(post_params)
      flash[:success] = "Object was successfully updated"
      redirect_to @post
    else
      flash[:error] = "Something went wrong"
      render 'edit', status: :unprocessable_entity
    end
  end
  
  def destroy
    @post = Post.find(params[:id])

    if @post.destroy
      flash[:success] = 'Post was successfully deleted.'
      redirect_to posts_url
    else
      flash[:error] = 'Something went wrong'
      redirect_to posts_url, status: :unprocessable_entity
    end
  end
  
  
  private

  def post_params
    params.require(:post).permit(:content, :post_image)
  end
end

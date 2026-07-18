# frozen_string_literal: true

class PostsController < PublicController
  def index
    @category = params[:category].presence
    @posts = Post.live.recent
    @posts = @posts.where(category: @category) if @category
    @categories = Post.live.distinct.pluck(:category).compact_blank.sort
  end

  def show
    @post = Post.live.find_by!(slug: params[:slug])
  end
end

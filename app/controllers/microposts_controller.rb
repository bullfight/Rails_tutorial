class MicropostsController < ApplicationController
  before_filter :authenticate, :only => [:create, :destroy]
  before_filter :authorized_user, :only => :destroy

  def create
    @micropost  = current_user.microposts.build(params[:micropost])
    @micropost.in_reply_to = reply(params[:micropost])

    if @micropost.save
      flash[:success] = "Post created!"
      redirect_to root_path
    else
      @feed_items = []
      render 'pages/home'
    end
  end

  def destroy
    @micropost.destroy
    redirect_back_or root_path
  end
  
  private
    
    def authorized_user
      @micropost = current_user.microposts.find_by_id(params[:id])
      redirect_to root_path if @micropost.nil?
    end
    
    def reply(micropost)
      User.find_by_username(reply_to_user(micropost))
    end
    
    def reply_to_user(micropost)
      reply_regex = /^@([\w+\-.]+)/i
      user_name = micropost["content"].match(reply_regex)
      return nil if user_name.nil?
      return user_name[1] if !user_name.nil?
    end
end

class PagesController < ApplicationController
  def home
    @title = "Home"
    @micropost = Micropost.new if signed_in?
    @feed_items = current_user.feed.page(params[:page]).per(10)
  end
  
  def contact
    @title = "Contact"
  end
  
  def about
    @title = "About"
  end

  def help
    @title = "Help"
  end

end

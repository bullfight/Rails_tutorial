class PagesController < ApplicationController
  
  def home
    @title = "Home"
    if signed_in?
      @micropost = Micropost.new if signed_in?
      @feed_items = current_user.feed.page(params[:page]).per(1)
    end
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

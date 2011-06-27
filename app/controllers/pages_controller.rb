class PagesController < ApplicationController
  
  def home
    @title = "Sign in"
    if signed_in?
      @title = "Feed"
      @micropost = Micropost.new if signed_in?
      @feed_items = current_user.feed.page(params[:page]).per(5)
    end
    
    respond_to do |format|  
      format.html
      format.js   { render :nothing => true }  
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

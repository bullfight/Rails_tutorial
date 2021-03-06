class UsersController < ApplicationController
  before_filter :authenticate, :except => [:new, :create]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user,   :only => :destroy
  before_filter :sign_out_first,  :only => [:new, :create]
  
  def index
    @title = "All users"
    @users = User.order(:name).page(params[:page]).per(6)
  end
  
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.page(params[:page]).per(10)
    @title = @user.name
  end
    
  def new
    @user = User.new
    @title = "Sign up"
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome and please, FEED ME!"
      redirect_to @user
    else
      @title = "Sign up"
      @user.password = nil
      @user.password_confirmation = nil
      flash[:error] = "Sorry about that, please try again."
      render 'new'      
    end
  end
  
  def edit
    @title = "Edit Your Account Settings"
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      flash[:error] = "Sorry about that, please try again."
      render 'edit'
    end
  end
  
  def destroy
    user = User.find(params[:id])
    user.destroy unless user == current_user
    flash[:success] = "User destroyed."
    redirect_to users_path
  end
  
  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.page(params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.page(params[:page])
    render 'show_follow'
  end
  
  def replies
    @title = "Replies"
    @user = User.find(params[:id])
    @feed_items = @user.replies.page(params[:page])
    render 'show_replies'
  end
  
  private
    
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
    
    def admin_user
      redirect_to(root_path, 
        :notice => "Must be admin to perform this action") unless current_user.admin?
    end
    
    def sign_out_first
      redirect_to(root_path, 
        :notice => "Sign out to create a new user") unless signed_in? == false
    end

end

class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end
  
  def create
    user = User.authenticate(params[:session][:login],
                             params[:session][:password])
    if user.nil?
      flash[:error] = "Invalid username or email/password combination."
      @title = "Sign in"
      render 'new'
    else
      sign_in user
      redirect_back_or user
    end
    
  end
  
  def destroy
    sign_out
    redirect_to root_path    
  end

end

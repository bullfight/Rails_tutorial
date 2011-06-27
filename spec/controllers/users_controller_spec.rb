require 'spec_helper'

describe UsersController do
  render_views
  
  describe "GET 'index'" do
  
    describe "for non-signed-in users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    end
    
    describe "for non-admin signed-in users" do
      
      before(:each) do
        @user = test_sign_in(Factory(:user))

        @users = [@user]
        30.times do 
          @users << Factory(:user, 
                            :username => Factory.next(:username), 
                            :email => Factory.next(:email))
        end
      end
      
      it "should be successful" do
        get :index
        response.should be_success
      end
      
      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "All users")
      end
      
      it "should have an element for each user" do
        get :index
        @users[0..2].each do |user|
          response.should have_selector("div", :content => user.name)
        end
      end
      
      it "should not have delete link on any users" do
        get :index
        @users[0..2].each do |user|
          response.should_not have_selector "a",
            :href => user_path(user),
            :"data-method" => "delete"
        end      
      end
      
      it "should paginate users" do
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Newer")
        response.should have_selector("a", :href => "/users?page=2", :content => "Older")      
      end
    end #signed in users 
    
    describe "as an admin user" do
      before(:each) do
        admin = Factory(:user, :email => "admin@example.com", :admin => true)
        test_sign_in(admin)
        
        @users = [admin]
        30.times do 
          @users << Factory(:user, 
                            :username => Factory.next(:username), 
                            :email => Factory.next(:email))
        end
      end
      
      it "should have delete link for each user" do
        get :index
        @users[0..2].each do |user|
          response.should have_selector "a",
          :href => user_path(user), 
          :"data-method" => "delete"
        end
      end
    end
       
  end # get index
  
  describe "GET 'show'" do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    describe "for non-signed-in users" do
      it "should deny access" do
        get :show, :id => @user
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    end
    
    describe "for signed-in users" do
      
      before(:each) do
        @user = test_sign_in(@user)
        @mp1 = Factory(:micropost, :user => @user, :content => "Foo bar")
        @mp2 = Factory(:micropost, :user => @user, :content => "Baz quux")        
      end
      
      it "should be successful" do
        get :show, :id => @user
        response.should be_success
      end
    
      it "should find the right user" do
        get :show, :id => @user
        assigns(:user).should == @user
      end
    
      it "should have the right title" do
        get :show, :id => @user
          response.should have_selector("title", :content => @user.name)
      end
    
      it "should include the user's name"do
         get :show, :id => @user
         response.should have_selector("h2", :content => @user.name)
       end
    
      it "should have a profile image" do
        get :show, :id => @user
        response.should have_selector("img", :class => "gravatar")
      end
    
      it "should show the user's microposts" do
        get :show, :id => @user
        response.should have_selector("div.feed-item", :content => @mp1.content)
        response.should have_selector("div.feed-item", :content => @mp2.content)
      end
      
      it "should count the user's microposts in the profile nav" do
        count = @user.microposts.count
        
        get :show, :id => @user
        response.should have_selector("div#profile_header nav li",
          :content => "Posts (#{count})")
      end
    end # signed in
  end # get 'show'
    
  describe "GET 'new'" do
    
    it "should be successful" do
      get :new
      response.should be_success
    end
    
    it "should have the right title" do
      get :new
      response.should have_selector("title", :content => "Sign up")
    end
  
    it "should have a name field" do
      get :new
      response.should have_selector("input[name='user[name]'][type='text']")
    end

    it "should have an email field" do
      get :new
      response.should have_selector("input[name='user[email]'][type='text']")
    end
    it "should have a password field" do
      get :new
      response.should have_selector("input[name='user[password]'][type='password']")
    end
    it "should have a password confirmation field" do
      get :new
      response.should have_selector("input[name='user[password_confirmation]'][type='password']")
    end
    
    describe "signed-in user" do
      before(:each) do
        @user = Factory(:user)
        test_sign_in(@user)
      end
      
      it "should redirect to root" do
       get :new
       response.should redirect_to(root_path)      
      end      
    end
  end # get 'new'
  
  describe "POST 'create'" do

    describe "failure" do

      before(:each) do
        @attr = { :name => "", :username => "", :email => "", :password => "",
          :password_confirmation => "" }
      end

      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end

      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector("title", :content => "Sign up")
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end
      
      it "should reset the user password param" do
        post :create, :user => @attr
        assigns(:user).password.should be_nil
      end
      
      it "should reset the user password_confirmation param" do
        post :create, :user => @attr
        assigns(:user).password_confirmation.should be_nil
      end
    end
  
    describe "success" do

      before(:each) do
       @attr = { :username => "NewUser", :name => "New User", :email => "user@example.com",
                 :password => "foobar", :password_confirmation => "foobar" }
      end

      it "should create a user" do
       lambda do
         post :create, :user => @attr
       end.should change(User, :count).by(1)
      end

      it "should redirect to the user show page" do
       post :create, :user => @attr
       response.should redirect_to(user_path(assigns(:user)))
      end    

      it "should have a welcome message" do
       post :create, :user => @attr
       flash[:success].should =~ /feed me/i
      end
       
      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end
    end # Success
    
    describe "signed-in user" do
      before(:each) do
        @user = Factory(:user)
        test_sign_in(@user)
      end
      
      it "should redirect to root" do
       post :create
       response.should redirect_to(root_path)      
      end      
    end
    
  end # end POST 'create'
  
  describe "GET 'edit'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    
    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end
    
    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector("title", :content => "Edit Your Account Settings")
    end
    
    it "should have a link to change the Gravitar" do
      get :edit, :id => @user
      gravitar_url = "http://gravatar.com/emails"
      response.should have_selector("a", :href => gravitar_url, :content => "change")
    end
  
  end
  
  describe "PUT 'update'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end
    
    describe "failure" do
      @attr = { :email => "", :name => "", :username => "", :password => "",
                :password_confirmation => "" }
      
      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end
      
      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector("title", :content => "Edit user")
      end
    end
    
    describe "success" do
      before(:each) do
        @attr = { :username => "foolbarz", :name => "New Name", :email => "user@example.org",
                  :password => "barbaz", :password_confirmation => "barbaz" }
      end
      it "should change the user's attributes" do
        put :update, :id => @user, :user => @attr
        @user.reload
        @user.name.should == @attr[:name]
        @user.username.should == @attr[:username] 
        @user.email.should == @attr[:email]
      end
      it "should redirect to the user show page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end
      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end
    end
  
  end #put update
  
  describe "authentication of edit/update pages" do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    describe "for non-signed in users" do

      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end
      
      it "should deny access to 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end
      
    end #non signed in
    
    describe "for signed-in users" do
     
      before(:each) do
        wrong_user = Factory(:user,
                             :username => Factory.next(:username),
                             :email => Factory.next(:email))
        test_sign_in(wrong_user)
      end
      
      it "should require matching users for 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end
      
      it "should require matching users for 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
      
    end # signed-in
    
  end #authentication
  
  describe "Delete 'destroy'" do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    describe "as a non-signed-in user" do
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end
      
    describe "as a non-admin user" do
      it "should protect the page" do 
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end #non-admin
                
    describe "as an admin user" do
      before(:each) do
         @admin = Factory(:user, 
                          :username => Factory.next(:username),
                          :email => Factory.next(:email), 
                          :admin => true)
         test_sign_in(@admin)
       end
       
       it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
       end
       
       it "should not destroy self" do
         lambda do
           delete :destroy, :id => @admin
         end.should change(User, :count).by(0)
       end
       
       it "should rediret to the users page" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
       end       
    end #as admin  
  end # Delete 'destroy'

  describe "follow pages" do

    describe "when not signed in" do

      it "should protect 'following'" do
        get :following, :id => 1
        response.should redirect_to(signin_path)
      end

      it "should protect 'followers'" do
        get :followers, :id => 1
        response.should redirect_to(signin_path)
      end
    end # not signed in

    describe "when signed in" do

      before(:each) do
        @user = test_sign_in(Factory(:user))
        @other_user = Factory(:user, 
                              :username => Factory.next(:username),
                              :email => Factory.next(:email))
        @user.follow!(@other_user)
      end
      
      describe "users following show page" do
        it "should show user following" do
          get :following, :id => @user
          response.should have_selector("a", :href => user_path(@other_user),
                                             :content => @other_user.name)
        end

      
        it "should count the number of user following in the profile nav" do
          count = @user.following.count
                
          get :show, :id => @user
          response.should have_selector("div#profile_header nav li",
            :content => "Following (#{count})")
        end      
      end #following
      
      describe "users follower show page" do

        it "followed user should show users following" do
          get :followers, :id => @other_user
          response.should have_selector("a", :href => user_path(@user),
                                             :content => @user.name)
        end
      
        it "should count the number of user followers in the profile nav" do
          count = @other_user.followers.count
        
          get :show, :id => @other_user
          response.should have_selector("div#profile_header nav li",
            :content => "Followers (#{count})")
        end
      end #followers
      
    end # signed in
  end # follow

end

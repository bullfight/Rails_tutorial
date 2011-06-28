require 'spec_helper'

describe Micropost do

  before(:each) do 
    @user = Factory(:user)
    @followed_user = Factory(:user, 
                             :username => Factory.next(:username), 
                             :email => Factory.next(:email))
    @unfollowed_user = Factory(:user, 
                               :username => Factory.next(:username), 
                               :email => Factory.next(:email))
    @second_unfollowed_user = Factory(:user, 
                                      :username => Factory.next(:username), 
                                      :email => Factory.next(:email))                               
                               
    @attr = { :content => "value for content" }                               
    
    @user_post = @user.microposts.create!(@attr)
    @followed_user_post = @followed_user.microposts.create!(@attr)
    @unfollowed_user_post = @unfollowed_user.microposts.create!(@attr)
    @reply_to_user_post = @unfollowed_user.microposts.create!(
                            :content => "@#{@user.username} foo", 
                            :in_reply_to => @user.id)
    @unfollowed_reply = @unfollowed_user.microposts.create!(
                          :content => "@#{@second_unfollowed_user.username} foo",
                          :in_reply_to => @second_unfollowed_user.id)
        
    @user.follow!(@followed_user)
  end

  it "should create a new instance given valid attributes" do
    @user.microposts.create!(@attr)
  end
  
  describe "user associations" do
    before(:each) do
      @micropost = @user.microposts.create(@attr)
    end
    
    it "should have a user attribute" do
      @micropost.should respond_to(:user)
    end
      
    it "should have the right associated user" do
      @micropost.user_id.should == @user.id
      @micropost.user.should == @user
    end
    
    it "should require a user_id" do
      Micropost.new(@attr).should_not be_valid
    end
    
    it "should require nonblank content" do
      @user.microposts.build(:content => "  ").should_not be_valid
    end
    
    it "should reject long content" do
      @user.microposts.build(:content => "a" * 141).should_not be_valid
    end
    
  end #associations
  
  describe "micropost in_reply_to another user" do
    
    it "should have in_reply_to attribute" do
      @reply_to_user_post.should respond_to(:in_reply_to)
    end
    
    it "should have an user associated with the reply" do
      @reply_to_user_post.in_reply_to.should == @user.id
    end
        
  end
  
  describe "from users followed by" do
    
    it "should have a from_users_followed_by class method" do
    Micropost.should respond_to(:from_users_followed_by)
    end

    it "shoud incude the user's own microposts" do
    Micropost.from_users_followed_by(@user).should include(@user_post)
    end

    it "shoud incude the followed user's microposts" do
    Micropost.from_users_followed_by(@user).should include(@followed_user_post)
    end

    it "should not include an unfollowed user's microposts" do
    Micropost.from_users_followed_by(@user).should_not include(@unfollowed_user_post)
    end
      
  end
    
  describe "reply from users" do
    
    it "should have an including_replies methods" do
      Micropost.should respond_to(:from_replies)
    end

    it "should incude replies to the user" do
      Micropost.from_replies(@user).should include(@reply_to_user_post)
    end

    it "should not include replies to another user if unfollowed" do
      Micropost.from_replies(@user).should_not include(@unfollowed_reply)
    end
      
  end
  
  describe "from followers or replies" do
    
    it "should have an including_replies methods" do
      Micropost.should respond_to(:from_followed_or_replies)
    end
    
    it "should incude the user's own microposts" do
      Micropost.from_followed_or_replies(@user).should include(@user_post)
    end
    
    it "should incude replies to the user" do
      Micropost.from_followed_or_replies(@user).should include(@reply_to_user_post)
    end
    
    it "should incude the followed user's microposts" do
      Micropost.from_followed_or_replies(@user).should include(@followed_user_post)
    end
    
    it "should not incude replies to another user if unfollowed" do
      Micropost.from_followed_or_replies(@user).should_not include(@unfollowed_reply)
    end
    
    it "should not include replies to another user if unfollowed" do
      Micropost.from_followed_or_replies(@user).should_not include(@unfollowed_reply)
    end
  end

end
require 'spec_helper'

describe Micropost do

  before(:each) do 
    @user = Factory(:user)
    @attr = { :content => "value for content" }
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
    
    before(:each) do
      @other_user = Factory(:user,
                            :username => Factory.next(:username),
                            :email => Factory.next(:email))
      @attr = { :content => "@#{@other_user.username} Reply to other_user",
                :in_reply_to => @other_user.id }
      
      @micropost = @user.microposts.create(@attr)
    end
    
    it "should have in_reply_to attribute" do
      @micropost.should respond_to(:in_reply_to)
    end
    
    it "should have an user associated with the reply" do
      @micropost.in_reply_to.should == @other_user.id
    end
    
    
  end
  
  describe "from users followed by" do
    
    before(:each) do
      @other_user = Factory(:user, 
                            :username => Factory.next(:username), 
                            :email => Factory.next(:email))
      @third_user = Factory(:user, 
                            :username => Factory.next(:username), 
                            :email => Factory.next(:email))
      
      @user_post = @user.microposts.create!(:content => "foo")
      @other_post = @other_user.microposts.create!(:content => "bar")
      @third_post = @third_user.microposts.create!(:content => "baz")
      
      @user.follow!(@other_user)
    end
    
    it "should have a from_users_followed_by class method" do
    Micropost.should respond_to(:from_users_followed_by)
    end

    it "shoud incude the user's own microposts" do
    Micropost.from_users_followed_by(@user).should include(@user_post)
    end

    it "shoud incude the followed user's microposts" do
    Micropost.from_users_followed_by(@user).should include(@other_post)
    end

    it "should not include an unfollowed user's microposts" do
    Micropost.from_users_followed_by(@user).should_not include(@third_post)
    end
      
  end
  
  
  describe "reply from other users" do
    
    before(:each) do
      @other_user = Factory(:user, 
                            :username => Factory.next(:username), 
                            :email => Factory.next(:email))
      @third_user = Factory(:user, 
                            :username => Factory.next(:username), 
                            :email => Factory.next(:email))
      
      @other_post = @other_user.microposts.create!(:content => "@#{@user.username} bar", 
                                                   :in_reply_to => @user.id)                                                   
      @second_post = @other_user.microposts.create!(:content => "@#{@third_user.username} foo", 
                                                   :in_reply_to => @third_user.id)
      @third_post = @third_user.microposts.create!(:content => "baz")                                                   
                                                   
    end
    
    it "should have an including_replies methods" do
      Micropost.should respond_to(:from_replies)
    end

    it "should incude replies to the user" do
      Micropost.from_replies(@user).should include(@other_post)
    end

    it "should not include an unfollowed user's microposts" do
      Micropost.from_replies(@user).should_not include(@second_post)
    end
      
  end
  
  describe "from followers and replies" do
    
    before(:each) do
      @other_user = Factory(:user, 
                            :username => Factory.next(:username), 
                            :email => Factory.next(:email))
      @third_user = Factory(:user, 
                            :username => Factory.next(:username), 
                            :email => Factory.next(:email))
      
      @user_post = @user.microposts.create!(:content => "foo")
      @other_post = @other_user.microposts.create!(:content => "@#{@user.username} bar", 
                                                   :in_reply_to => @user.id)                                                   
      @third_post = @third_user.microposts.create!(:content => "@#{@other_user.username} foo", 
                                                   :in_reply_to => @other_user.id)
                                                   
      @user.follow!(@other_user)                                                   
    end
    
    it "should have an including_replies methods" do
      Micropost.should respond_to(:from_followed_and_replies)
    end
    
    it "should incude the user's own microposts" do
      Micropost.from_followed_and_replies(@user).should include(@user_post)
    end
    
    it "should incude replies to the user" do
      Micropost.from_followed_and_replies(@user).should include(@other_post)
    end
    
    it "should incude the followed user's microposts" do
      Micropost.from_followed_and_replies(@user).should include(@other_post)
    end
    
    it "should not incude replies to another user or if unfollowed" do
      Micropost.from_followed_and_replies(@user).should_not include(@third_post)
    end
  end

end
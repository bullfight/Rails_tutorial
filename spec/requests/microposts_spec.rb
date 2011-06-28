require 'spec_helper'

describe "Microposts" do

  before(:each) do
    user = Factory(:user)
    visit signin_path
    fill_in :"Username or Email",    :with => user.email
    fill_in :password, :with => user.password
    click_button
  end

  describe "creation" do

    describe "failure" do

      it "should not make a new micropost" do
        lambda do
          visit root_path
          fill_in :micropost_content, :with => ""
          click_button
          response.should render_template('pages/home')
          response.should have_selector("div#error_explanation")
        end.should_not change(Micropost, :count)
      end
    end # failure

    describe "success" do

      it "should make a new micropost" do
        content = "Lorem ipsum dolor sit amet"
        lambda do
          visit root_path
          fill_in :micropost_content, :with => content
          click_button
          response.should have_selector("div.feed-item", :content => content)
        end.should change(Micropost, :count).by(1)
      end
    end # success
    
    describe "successful reply" do
      before(:each) do
        @reply_to_user = Factory(:user, 
                                :username => Factory.next(:username),
                                :email => Factory.next(:email))
      end
      
      it "should make a new micropost" do        
        lambda do
          content = "@#{@reply_to_user.username} Lorem ipsum dolor sit amet"
          visit root_path
          fill_in :micropost_content, :with => content
          click_button
          response.should have_selector("div.feed-item", :content => content)
        end.should change(Micropost, :count).by(1)
      end
      
      it "should make show up in feed of user at which it was directed" do        
        lambda do
          content = "@#{@reply_to_user.username} Lorem ipsum dolor sit amet"
          visit root_path
          fill_in :micropost_content, :with => content
          click_button
          response.should have_selector("div.feed-item", :content => content)
        end.should change(@reply_to_user.feed, :count).by(1)
      end
    
    end
    
  end # creation
  
end # Microposts
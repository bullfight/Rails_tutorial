require 'spec_helper'

describe PagesController do
  render_views
  
  before (:each) do
    @base_title = "Ruby on Rails Tutorial Sample App"
  end
  
  ["contact", "about", "help"].each do |page|
    
    describe "GET #{page}" do
      it "should be successful" do
        get page
        response.should be_success
      end

      it "should have the right title" do
        get page
        response.should have_selector("title",
          :content => @base_title + " | " + page.capitalize )
      end
    end
    
  end
  
  describe "GET 'home'" do
    describe "when not signed in" do

        before(:each) do
          get :home
        end

        it "should be successful" do
          response.should be_success
        end

        it "should have the right title" do
          response.should have_selector("title",
                                        :content => "#{@base_title} | Home")
        end
      end # not signed in

      describe "when signed in" do

        before(:each) do
          @user = test_sign_in(Factory(:user))
          other_user = Factory(:user, :email => Factory.next(:email))
          other_user.follow!(@user)
        end

        it "should have the right follower/following counts" do
          get :home
          response.should have_selector("div#micropost_form")
        end
      end #signed in

  end # get home
  
end

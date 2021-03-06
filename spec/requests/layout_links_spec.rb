require 'spec_helper'

describe "LayoutLinks" do
  
  it "should have a Home page at '/'" do
    get '/'
    response.should have_selector('title', :content => "Feed")
  end
  
  ["contact", "about", "help"].each do |page|
    it "should have a #{page.capitalize} page at /#{page}" do
      get "/#{page}"
      response.should have_selector('title', :content => page.capitalize)
    end
  end
  
  it "should have a signup page at '/signup'" do
    get '/signup'
    response.should have_selector('title', :content => "Sign up")
  end
  
  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    response.should have_selector('title', :content => "About")
    click_link "Help"
    response.should have_selector('title', :content => "Help")
    click_link "Contact"
    response.should have_selector('title', :content => "Contact")
    #click_link "Sign up now!"
    #response.should have_selector('title', :content => "Sign up")
  end
  
  describe "when not signed in" do
    it "should have a signin panel" do
      visit root_path
      response.should have_selector("div#signin")
      response.should have_selector("input", :value => "Sign in")
    end
  end

  describe "when signed in" do

    before(:each) do
      @user = Factory(:user)
      visit signin_path
      fill_in :"Username or Email",    :with => @user.email
      fill_in :password, :with => @user.password
      click_button
    end

    it "should have a signout link" do
      visit root_path
      response.should have_selector("a", :href => signout_path,
                                         :content => "Sign out")
    end

    it "should have the right links" do
      visit root_path
      response.should have_selector("a", :href => root_path,
        :content => "Feed")
      response.should have_selector("a", :href => users_path,
        :content => "Users")
      response.should have_selector("a", :href => user_path(@user),
        :content => "Profile")
    end
    
    it "should have a settings link" do
      visit root_path
      response.should have_selector("a", :href => edit_user_path(@user),
                                         :content => "Account Settings")
    end
  end
  
end

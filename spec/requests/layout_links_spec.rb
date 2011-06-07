require 'spec_helper'

describe "LayoutLinks" do
  
  it "should have a Home page at '/'" do
    get '/'
    response.should have_selector('title', :content => "Home")
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
  
end

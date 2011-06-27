namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    make_users
    make_microposts
    make_relationships
  end
end
    
def make_users    
  admin = User.create!(:username => "ExampleUser",
                       :name => "Example User",
                       :email => "example@example.com",
                       :password => "foobar",
                       :password_confirmation => "foobar")
  admin.toggle!(:admin)
    
  99.times do |n|
    username = "ExampleUser_#{n+1}"
    name  = Faker::Name.name
    email = "example-#{n+1}@example.com"
    password  = "password"
    User.create!(
                 :username => username,
                 :name => name,
                 :email => email,
                 :password => password,
                 :password_confirmation => password)
  end
end

def make_microposts
  50.times do
    User.all(:limit => 6).each do |user|
      1.times do
        content = Faker::Lorem.sentence(5)
        user.microposts.create!(:content => content)
      end
      1.times do
        content = "@ExampleUser #{Faker::Lorem.sentence(5)}"
        user.microposts.create!(:content => content, :in_reply_to => 1)
      end
    end
  end
end
    
def make_relationships
  users = User.all
  user = users.first
  following = users[1..50]
  followers = users[3..40]
  following.each { |followed| user.follow!(followed) }
  followers.each { |follower| follower.follow!(follower) }
end
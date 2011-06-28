Factory.sequence :email do |n|
  "email#{n}@factory.com"
end

Factory.sequence :username do |n|
  "username#{n}"
end

Factory.define :user do |user|
  user.username { Factory.next(:username) }
  user.name "Patrick Schmitz"
  user.email { Factory.next(:email) }
  user.password "foobar"
  user.password_confirmation "foobar"
  user.admin false
end

Factory.define :micropost do |micropost|
  micropost.content "Foo bar"
  micropost.association :user
end
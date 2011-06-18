Factory.define :user do |user|
  user.name "Patrick Schmitz"
  user.email "ps@example.com"
  user.password "foobar"
  user.password_confirmation "foobar"
end

Factory.sequence :email do |n|
  "person-#{n}@example.com"
end
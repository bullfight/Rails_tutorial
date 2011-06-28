#https://gist.github.com/300536
# or my fork https://gist.github.com/1050917

# a simple/configurable rake task that generates some random fake data for the app (using faker) at various sizes
# NOTE: requires the faker or ffaker gem 
#   sudo gem install faker - http://faker.rubyforge.org
#   OR
#   sudo gem install ffaker - http://github.com/EmmanuelOga/ffaker

require 'faker'

class Fakeout

  # START Customizing

  # 1. first these are the model names we're going to fake out, note in this example, we don't create tags/taggings specifically
  # but they are defined here so they get wiped on the clean operation
  # e.g. this example fakes out, Users, Questions and Answers, and in doing so fakes some Tags/Taggings
  MODELS = %w(User Micropost Relationship)

  # 2. now define a build method for each model, returning a list of attributes for Model.create! calls
  # check out the very excellent faker gem rdoc for faking out anything from emails, to full addresses; http://faker.rubyforge.org/rdoc
  # NOTE: a build_??? method MUST exist for each model you specify above
  def build_user(name = "#{Faker::Name.name}", username = "#{Faker::Internet.user_name}_#{random_letters}", email = Faker::Internet.email, password = 'password')
    time = fake_time_from(1.year.ago)
    
    { :name                  => name,
      :username              => username,
      :email                 => email,
      :password              => password,
      :password_confirmation => password,
      :created_at => time,
      :updated_at => time
    }
  end

  def create_micropost(user = pick_random(User))
    user.microposts.create!(
      :content => "#{Faker::Lorem.sentence(5)}"
    )
    
    reply_user = pick_random(User)
    until user != reply_user
      reply_user = pick_random(User)
    end
    
    user.microposts.create!(
      :content => "@#{reply_user.username} #{Faker::Lorem.sentence(5)}",
      :in_reply_to => reply_user.id
    )
    
  end

  def create_relationship(follower = pick_random(User))
    followed = pick_random(User)
        
    #ensure follower and followed are not the same and is not already followed    
    until followed != follower and !follower.following?(followed)
      followed = pick_random(User)
    end
    
    follower.follow!(followed)
  end

  # return nil, or an empty hash for models you don't want to be faked out on create, but DO want to be clearer away
  #def build_tag; end
  #def build_tagging; end
  
  # called after faking out, use this method for additional updates or additions
  def post_fake
    admin = User.create!(build_user('Patrick Schmitz', 'admin', 'admin@feedme.com', 'foobar'))
    admin.toggle!(:admin)
    create_micropost(admin)
    create_relationship(admin)
  end

  # 3. optionally you can change these numbers, basically they are used to determine the number of models to create
  # and also the size of the tags array to choose from.  To check things work quickly use the tiny size (1 for everything)
  def tiny
    1
  end
  
  def small
    25+rand(50)
  end

  def medium
    250+rand(250)
  end

  def large
    1000+rand(500)
  end

  # END Customizing

  attr_accessor :all_tags, :size

  def initialize(size, prompt=true)
    self.size     = size
    self.all_tags = Faker::Lorem.words(send(size))
  end

  def fakeout
    puts "Faking it ... (#{size})"
    Fakeout.disable_mailers
    MODELS.each do |model|
      if !respond_to?("build_#{model.downcase}")
        puts "  * #{model.pluralize}: **warning** I couldn't find a build_#{model.downcase} method"
        next
      end
      1.upto(send(size)) do
        attributes = send("build_#{model.downcase}")
        model.constantize.create!(attributes) if attributes && !attributes.empty?
      end
      puts "  * #{model.pluralize}: #{model.constantize.count(:all)}"
    end
    
    MODELS.each do |model|
      if !respond_to?("create_#{model.downcase}")
        puts "  * #{model.pluralize}: **warning** I couldn't find a create_#{model.downcase} method"
        next
      end
      1.upto(send(size)) do
        send("create_#{model.downcase}")        
      end
      puts "  * #{model.pluralize}: #{model.constantize.count(:all)}"
    end
    
    post_fake
    puts "Done, I Faked it!"
  end
  
  def self.prompt
    puts "Really? This will clean all #{MODELS.map(&:pluralize).join(', ')} from your #{RAILS_ENV} database y/n? "
    STDOUT.flush
    (STDIN.gets =~ /^y|^Y/) ? true : exit(0)
  end

  def self.clean(prompt = true)
    self.prompt if prompt
    puts "Cleaning all ..."
    Fakeout.disable_mailers
    MODELS.each do |model|
      model.constantize.delete_all
    end
  end

  # by default, all mailings are disabled on faking out
  def self.disable_mailers
    ActionMailer::Base.perform_deliveries = false
  end
  
  
  private
  # pick a random model from the db, done this way to avoid differences in mySQL rand() and postgres random()
  def pick_random(model, optional = false)
    return nil if optional && (rand(2) > 0)
    ids = ActiveRecord::Base.connection.select_all("SELECT id FROM #{model.to_s.tableize}")
    model.find(ids[rand(ids.length)]["id"].to_i) unless ids.blank?
  end

  # useful for prepending to a string for getting a more unique string
  def random_letters(length = 2)
    Array.new(length) { (rand(122-97) + 97).chr }.join
  end

  # pick a random number of tags up to max_tags, from an array of words, join the result with seperator
  def random_tag_list(tags, max_tags = 5, seperator = ',')
    start = rand(tags.length)
    return '' if start < 1
    tags[start..(start+rand(max_tags))].join(seperator)
  end

  # fake a time from: time ago + 1-8770 (a year) hours after
  def fake_time_from(time_ago = 1.year.ago)
    time_ago+(rand(8770)).hours
  end
end


# the tasks, hook to class above - use like so;
# rake fakeout:clean
# rake fakeout:small[noprompt] - no confirm prompt asked, useful for heroku or non-interactive use
# rake fakeout:medium RAILS_ENV=bananas
#.. etc.
namespace :fakeout do

  desc "clean away all data"
  task :clean, [:no_prompt] => :environment do |t, args|
    Fakeout.clean(args.no_prompt.nil?)
  end
  
  desc "fake out a tiny dataset"
  task :tiny, [:no_prompt] => :clean do |t, args|
    Fakeout.new(:tiny).fakeout
  end

  desc "fake out a small dataset"
  task :small, [:no_prompt] => :clean do |t, args|
    Fakeout.new(:small).fakeout
  end

  desc "fake out a medium dataset"
  task :medium, [:no_prompt] => :clean do |t, args|
    Fakeout.new(:medium).fakeout
  end

  desc "fake out a large dataset"
  task :large, [:no_prompt] => :clean do |t, args|
    Fakeout.new(:large).fakeout
  end
end
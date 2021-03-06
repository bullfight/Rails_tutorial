# == Schema Information
# Schema version: 20110627130429
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#  admin              :boolean
#  username           :string(255)
#

class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :username, :name, :email, :password, :password_confirmation
  has_many :microposts, :dependent => :destroy
  
  has_many :relationships, :foreign_key => "follower_id",
                           :dependent => :destroy                        
  has_many :following, :through => :relationships, :source => :followed
 
  has_many :reverse_relationships, :foreign_key => "followed_id",
                                   :class_name => "Relationship",
                                   :dependent => :destroy
  has_many :followers, :through => :reverse_relationships, 
                                   :source => :follower                           
  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  username_regex = /\A[\w+\-.]+$/i
  
  validates :username, :presence => true,
                    :format => { :with => username_regex},
                    :length => { :within => 4..50 },
                    :uniqueness => { :case_sensitive => false }
                    
  validates :name, :presence => true,
                   :length => { :maximum => 50 }
                   
  validates :email, :presence => true,
                    :format => { :with => email_regex} ,
                    :uniqueness => { :case_sensitive => false }
                    
  # Automatically create the virtual attribute 'password_confirmation'
  validates :password, :presence => true,
                       :confirmation => true,
                       :length => { :within => 6..40 }
  validates :password_confirmation, :presence => true
  
  before_save :encrypt_password
  
  # Return true if the user's password matched the submitted password.  
  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end
    
  def self.authenticate(login, submitted_password)
    if login.match(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
      user = find_by_email(login)
    else
      user = find_by_username(login)
    end
    return nil  if user.nil?
    return user if user.has_password?(submitted_password)
  end

  def self.authenticate_with_salt(id, cookie_salt)
   user = find_by_id(id)
   (user && user.salt == cookie_salt) ? user : nil
  end
  
  def following?(followed)
    relationships.find_by_followed_id(followed)
  end
  
  def follow!(followed)
    relationships.create!(:followed_id => followed.id) unless self == followed
  end
  
  def unfollow!(followed)
    relationships.find_by_followed_id(followed).destroy
  end
  
  def feed
    Micropost.from_followed_or_replies(self)
  end
  
  def replies
    Micropost.from_replies(self)
  end
  
  private
  
    def encrypt_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt(password)      
    end
    
    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end
    
    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end
    
    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
end

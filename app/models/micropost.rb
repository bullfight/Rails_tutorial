# == Schema Information
# Schema version: 20110627130429
#
# Table name: microposts
#
#  id          :integer         not null, primary key
#  content     :string(255)
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#  in_reply_to :integer
#

class Micropost < ActiveRecord::Base  
  attr_accessible :content, :in_reply_to
  belongs_to :user
  
  validates :content, :presence => true, :length => { :maximum => 140 }
  validates :user_id, :presence => true
  
  default_scope :order => 'microposts.created_at DESC'
  
  # Return microposts from the users being followed by the given user.
  scope :from_users_followed_by, lambda { |user| followed_by(user) }
  
  # Return microposts that are replies from other users
  scope :from_replies, lambda { |user| replies_to(user) }
  
  # Return Followed Users and replies
  scope :from_followed_and_replies, lambda { |user| replies_to(user) and followed_by(user) }
  
  private
    
    # Return a SQL condition for the users followed by the given user.
    # We include the user's own id as well.    
    def self.followed_by(user)
      following_ids = %(SELECT followed_id FROM relationships
                        WHERE follower_id = :user_id)      
      where("user_id IN (#{following_ids}) OR user_id = :user_id",
        { :user_id => user }
      )
    end
    
    def self.replies_to(user)
      where("in_reply_to = ? ", user)
    end
end

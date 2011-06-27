class AddReplyToMicroposts < ActiveRecord::Migration
  def self.up
    add_column :microposts, :in_reply_to, :integer, :default => nil
  end

  def self.down
    remove_column :microposts, :in_reply_to
  end
end

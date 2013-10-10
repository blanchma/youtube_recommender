class Follows < ActiveRecord::Base
  belongs_to :followed, :class_name => 'User', :foreign_key => 'followed_id'
  belongs_to :follower, :class_name => 'User', :foreign_key => 'follower_id'

  after_create :create_follow_event
  before_destroy :create_unfollow_event

  def create_follow_event
   puts "Creating FOLLOW event"
    follow = FollowEvent.new(:from_name => follower.nickname, :from_mtv_id => follower.id, :to_name => followed.nickname, :to_mtv_id => followed.id)
    follow.save
  end

  def create_unfollow_event
    puts "Creating UNFOLLOW event"
    UnfollowEvent.new(:from_name => follower.nickname, :from_mtv_id => follower.id, :to_name => followed.nickname, :to_mtv_id => followed.id)
  end


end


class EventsController < ApplicationController

  def index
    user_id = params[:user_id]
    last_event_id = params[:last_id]
    page = params[:page]
    
    if last_event_id.nil? || last_event_id.empty? 
      @events = Event.find_by_sql("SELECT e.* FROM events e WHERE e.to_mtv_id = #{user_id} OR (e.from_mtv_id IN (SELECT followed_id FROM follows WHERE follower_id = #{user_id}) AND event_type NOT IN ('FollowEvent', 'UnfollowEvent') ) ORDER BY e.created_at DESC").paginate(:page => page, :per_page => 10)
      #   @events = Event.where("e.from_mtv_id IN (SELECT id FROM follows WHERE follower_id = #{user_id})  OR e.to_mtv_id = #{user_id}").order("created_at ASC").paginate(:page => page, :per_page => 5)

      render :json => [@events.previous_page, @events, @events.next_page]
    else
      @new_events = Event.find_by_sql("SELECT e.* FROM events e WHERE e.id > #{last_event_id} AND (e.to_mtv_id = #{user_id} OR (e.from_mtv_id IN (SELECT followed_id FROM follows WHERE follower_id = #{user_id}) AND event_type NOT IN ('FollowEvent', 'UnfollowEvent') ) ) ORDER BY e.created_at ASC LIMIT 10")      

      render :json => @new_events
    end

  end

  def recommendations

  end

end


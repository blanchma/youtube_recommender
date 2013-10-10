require 'cron_logger'
#include ActionView::Helpers::UrlHelper

#MiniFB.fql(user.fb_token, "SELECT post_id, actor_id, target_id, message FROM stream WHERE source_id in (SELECT target_id FROM connection WHERE source_id=100000664267356 AND is_following=1) AND is_hidden = 0")


class SearchRecommendationsJob
  @queue=:high

  def self.perform(id=nil)
    if id.nil?
      for_all
    else
      only_user(id)
    end
  end #method

  def self.for_all
    User.to_search_recs.each do |user|
      puts "Search Facebook Recommendations for #{user.id} "
      search_recs(user)
    end #user each
  end


  def self.only_user(id)
    puts "Search Facebook Recommendations for user id:#{id} "
    user = User.find id
    if user.facebook?
      search_recs(user)
      user.update_attribute(:search_recs_at, Time.now) unless Rails.env == "development"
    end
  end

  def self.search_recs(user)
    @@youtube_client = YouTubeG::Client.new
    begin
      resp = MiniFB.get(user.fb_token, 'me', :type => 'home', :metadata=>true)
    rescue Exception => e
      puts "[Error SearchRecommendationsJob] #{e.message}"
      user.update_attribute(:fb_token, nil)
      return
    end

    resp.data.each do |post|
      parse(post,user)
    end
  end

  def self.parse(post, user)
    #puts "resp= #{resp.inspect}"
    puts "postId = #{post.id} (#{post.type })"
    return unless post.type == "video"
    return unless post.caption == 'www.youtube.com'
    return if user.facebook_recommendations.exists?(:post_id => post.id)
    return if user.fb_uid.to_s == post.from.id

    friend_id = post.from.id
    friend_username = post.from.name

    friend_picture = MiniFB.get(user.fb_token, friend_id, :fields => ['picture'])
    friend_pic_url = friend_picture.picture
    friend_email = nil
    begin
      friend_data = MiniFB.get(user.fb_token, friend_id, :fields => ['email'])
      friend_email = friend_data.try(:email) 
    rescue Exception => e
      puts "#{e.message}"
    end


    #        friend_pic_url = "https://graph.facebook.com/#{friend_id}/picture"
    puts "post_link = #{post.link}"
    begin
      post_link = URI.parse(post.link)
    rescue URI::InvalidURIError => e
      puts "URI::InvalidURIError"
      return
    end
    return unless post_link.query
    youtube_id = post_link.query.split('&').first.split('=')[1]
    puts "youtube_id => #{youtube_id}"
    video = Video.find_by_youtube_id(youtube_id)
    if video.nil?
      "Search video with YouTubeId = #{youtube_id}"
      youtube_video = @@youtube_client.video_by (youtube_id)
      p "embeddable? #{youtube_video.embeddable?}"
      video = youtube_video.to_mynewtv_video
      return if video.nil?
      video.save
    end

    video_id = video.id

    puts "VideoId = #{video_id}"

    fr = FacebookRecommendation.new(:post_id => post.id,
    :youtube_id => youtube_id,
    :video_id => video_id,
    :friend_id => friend_id,
    :friend_username => friend_username,
    :friend_pic_url => friend_pic_url,
    :friend_email => friend_email )

    friend_mynewtv = User.find_by_fb_uid friend_id
    fr.mynewtv_id = friend_mynewtv.id if friend_mynewtv


    puts "Finded FRecs from #{friend_username} about #{youtube_id}"

    #Dont remove
    user.facebook_recommendations << fr

    #user.save
  end




end


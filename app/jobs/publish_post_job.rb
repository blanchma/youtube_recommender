class PublishPostJob
  @queue = :high

  def self.perform(post_id=nil)
    if post_id
      # a specific post to publish
      post = Post.find(post_id)
      publish(post) unless post.published
    else
      # just iterate through unpublished posts and try to do them!
      posts = Post.unpublished.oldest
      pp posts
      posted = 0
      posts.each do |post|
        if post.user.nil? || post.video.nil?
          post.destroy
          next
        end
        
        #last_post = post.user.posts.published.latest.first
        #last_posted = 3.hour.ago
        #if (last_post)
          # they've posted before. when was it?
        #  last_posted = last_post.updated_at
        #end

        if (post.updated_at < 2.hours.ago)
          # okay, it's been 2 hours since last user post
          publish(post)
          posted += 1
        else
          puts "Too soon to post (#{post.updated_at} < #{2.hours.ago}): #{post.user.email} -> #{post.video.title}"
        end
      end
      puts "Published #{posted}, #{posts.count - posted} unpublished"

    end
  end

  def self.publish(post)
    if post.user.facebook? && post.user.publish_to_fb?
      puts "Publishing to Facebook: #{post.user.email} liked #{post.video.title}"
      begin
        # we have some facebook action
        fb = MiniFB::OAuthSession.new(post.user.fb_token)
        resp = fb.post('me', :type => :feed, :params => post.facebook_post_params)
        id = resp.id
        post.external_id = id
        post.published   = true
        post.save
      rescue MiniFB::FaceBookError => e
        puts "SOMETHING WENT WRONG WITH FB: #{e}"
      end
    end
    if post.user.twitter_connected? && post.user.publish_to_tw?
        puts "Publishing to Twitter: #{post.user.email} liked #{post.video.title}"
      begin
        auth = Twitter::OAuth.new TW_KEY, TW_SECRET
        auth.authorize_from_access(post.user.tw_token, post.user.tw_secret)
        twitter = Twitter::Base.new auth
        twitter.home_timeline(:count => 1)
        resp = twitter.update (post.twitter_post_params)
        post.published   = true
        post.save
      rescue Exception => e
        puts "SOMETHING WENT WRONG WITH TW: #{e}"
      end
    end

  end
end


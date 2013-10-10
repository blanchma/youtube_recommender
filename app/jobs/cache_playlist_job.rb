class CachePlaylistJob
    @queue = :low

  def self.perform(user_id)
      user = User.find user_id
      recommender = SphinxRecommender.new(user)
      video = recommender.pop_a_recommendation
      if video
        puts "Sphinx Recommender return #{video.id} - #{video.title}"
        #video.rating_from user
        user.playlist.append(video)
    end
  end
  
end

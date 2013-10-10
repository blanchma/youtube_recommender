class YouTubeG
  module Model
    class Video < YouTubeG::Record
      def to_mynewtv_video          
        p "#{title}-> embeddable? #{ embeddable?}"
        return unless embeddable?
        
        video = ::Video.new
        video.youtube_id     = unique_id
        video.author         = author.name
        video.categories     = categories.collect(&:label).join(', ')
       
        video.keywords       = keywords.join(', ').downcase
        video.keywords_count = keywords.size
        
        video.thumb_url     = thumbnails.find {|t| t.height <= 90}.url
        video.thumb_big_url = thumbnails.find {|t| t.height  > 90}.url
        
        if rating
          video.rating_min    = rating.min
          video.rating_max    = rating.max
          video.rating_avg    = rating.average
          video.rating_count  = rating.rater_count
        end
        
        [:duration, :racy, :published_at, :description, :title, :view_count, :favorite_count].each do |field|
          setter = "#{field}="
          val = self.send(field)
          # if val.respond_to?(:downcase!)
          #   val.downcase!
          # end
          video.send(setter, val)
        end
        
        return video
      end
    end
  end
end
=begin

class YouTubeIt
  module Model
    class Video < YouTubeIt::Record
      def to_mynewtv_video          

        return unless embeddable?
        
        video = ::Video.new
        video.youtube_id     = unique_id
        video.author         = author.name
        video.categories     = categories.collect(&:label).join(', ')
       
        video.keywords       = keywords.join(', ').downcase
        video.keywords_count = keywords.size
        
        video.thumb_url     = thumbnails.find {|t| t.height <= 90}.url
        video.thumb_big_url = thumbnails.find {|t| t.height  > 90}.url
        
        if rating
          video.rating_min    = rating.min
          video.rating_max    = rating.max
          video.rating_avg    = rating.average
          video.rating_count  = rating.rater_count
        end
        
        [:duration, :racy, :published_at, :description, :title, :view_count, :favorite_count].each do |field|
          setter = "#{field}="
          val = self.send(field)
          # if val.respond_to?(:downcase!)
          #   val.downcase!
          # end
          video.send(setter, val)
        end
        
        return video
      end
    end
  end
end
=end

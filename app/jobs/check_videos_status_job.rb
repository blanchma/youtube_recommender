
require 'pp'
#require 'net/http'
#require 'uri'
require 'net/http'


BROKEN_IMG = "/images/icons/broken.png"


class CheckVideosStatusJob
  @queue = :low

  def self.perform(id=nil)
    @videos_updated = []
    @videos_destroyed = []
    @client = YouTubeG::Client.new
    if id
      video=Video.find id
      check_video(video)
    else

      Video.select("id, youtube_id, thumb_url, thumb_big_url, updated_at").order("updated_at ASC").last(100).each do |video|

        check_video(video)
      end#videos
    end

    puts "videos updated", @videos_updated
    puts "videos destroyed", @videos_destroyed
  end

  def self.check_video(video)
    puts "Testing video #{video.id}"
    destroyed = false
    begin
      video_response = @client.video_by video.youtube_id
      #        url = URI.parse "http://youtube.com/watch?v=#{video.youtube_id}"
      #       req = Net::HTTP::Get.new(url.path)
      #puts "video_response = #{video_response}"
      unless video_response.embeddable?
        video.destroy
        @videos_destroyed  << {:id => video.id, :url => video.youtube_id}
        destroyed = true
        puts "is destroyable"
      end
    rescue OpenURI::HTTPError
      video.destroy
      @videos_destroyed  << {:id => video.id, :url => video.youtube_id}
      destroyed = true
      puts "is destroyable"
    end


=begin
      if video.thumb_url != BROKEN_IMG
          
        thumb_response = HTTParty.head video.thumb_url
        puts "thumb_response = #{thumb_response}"
        if thumb_response.response.class == Net::HTTPNotFound
          puts "       thumb_url(#{video.thumb_url}) broken"
          broken = true
          thumb_url = BROKEN_IMG
        end
      end

      if video.thumb_big_url != BROKEN_IMG
        thumb_big_response = HTTParty.head video.thumb_big_url
        thumb_big_url = video.thumb_big_url
        puts "thumb_big_response = #{thumb_big_response}"
        if thumb_big_response.response.class == Net::HTTPNotFound
          puts "       thumb_big_url(#{video.thumb_big_url}) broken"
          thumb_big_url = BROKEN_IMG
          broken = true
        end
      end
    end


    if !destroyed && broken
      puts "is broken but not destroyable"
      Video.connection.update_sql("UPDATE videos SET thumb_url='#{thumb_url}', thumb_big_url='#{thumb_big_url}', updated_at='#{Time.now}' WHERE id=#{video.id}")
      @videos_updated << {:id =>video.id, :thumb => video.thumb_url}
    end
=end
    if !destroyed #&& !broken
      puts "update but is good"
      Video.connection.update_sql("UPDATE videos SET updated_at='#{Time.now}' WHERE id=#{video.id}")
    end
  end


end#class


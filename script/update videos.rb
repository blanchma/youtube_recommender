# i=0
# ids = [5821, 6585, 6618, 6602, 6999, 7015, 7052, 7367, 7563, 8120, 8451, 8710, 8714, 9696, 9450, 9451, 9414, 9741, 9513, 9516, 9518, 9888, 9984, 10279, 10400, 10184, 10173, 10144, 10710, 10976, 11007, 11049, 11188]
# count =ids.size
# Video.where(:id => ids).each do |video|
class MissingYoutubeVideo < Exception; end
c = YouTubeG::Client.new
error_videos = []
i = 0
conditions = 'id>938193'
count = Video.where(conditions).count
Video.where(conditions).find_each do |video|
  i = i + 1
  begin
    ytv = c.video_by(video.youtube_id)
    unless ytv
      raise MissingYoutubeVideo.new("Missing: #{video.youtube_id}")
    end
  rescue Errno::ETIMEDOUT => e
    puts
    puts " * Timeout! Retrying!"
    retry
  rescue MissingYoutubeVideo, OpenURI::HTTPError => e
    if e.respond_to?(:io) && e.io.status[0] == '404'
      puts
      puts " * No load #{video.youtube_id}. Destroying."
      video.destroy
    else
      puts
      puts " * Error: #{e.inspect}. Video Id: #{video.id}. Continuing."
      puts
      error_videos << video.id
    end
    next
  end
    
  video.title       = ytv.title
  video.description = ytv.description
  if video.save
    print "#{video.id}, [#{i}/#{count}]..."
  else
    puts
    puts "Save failed for #{video.id}! #{video.errors.full_messages.to_sentence}"
    error_videos << video.id
  end
end


unless ARGV[0].nil?
  id_min = ARGV[0]
else
  id_min = 0
end
puts id_min

=begin
CategoryScore.all.each do |cs|
  cs.scoreable_type = "User"
  cs.save
end

Rates.all.each do |r|
  r.scoreable_type = "User"
  r.save
end

REDIS.keys("phrase*").each do |key|
  REDIS.del key
end
=end

    yc = YoutubeCrawler.new



  Video.where("id > ?", id_min).order("updated_at DESC").find_in_batches(:batch_size => 1000) do |videos|
    sleep 5
    videos.each do |vid|
      puts vid.id
      begin
      ytvid = yc.client.video_by(vid.youtube_id)
      vid.destroy unless ytvid.embeddable?
      rescue
        vid.destroy
      end
      vid.save unless vid.destroyed?
  end

  end



require 'cron_logger'

class ToplistJob
  @queue = :medium


  def self.perform_old
    toplist = Toplist.new
    most_liked_videos = []
    sql_offset = 0
    sql_limit = 10
    while most_liked_videos.size < 10
      most_liked = PhraseScore.most_liked.limit(sql_limit).offset(sql_offset)
      break if most_liked.to_a.size == 0
      sql_offset+=sql_limit

      phrase_ids = most_liked.collect {|likest| likest.phrase_id}
      videos_ids = videos_for_phrases (phrase_ids)
      next if videos_ids.size == 0
      new_videos = videos_ids - toplist.ids
      most_liked_videos+= new_videos
      most_liked_videos.uniq!
    end

    scored_videos= {}

    puts "most_liked_videos = #{most_liked_videos}"

    return if most_liked_videos.size == 0

    most_liked_videos.each do |vid|
      scored_videos[vid]=toplist.score_video vid
    end

    sorted_videos = scored_videos.sort { |a,b| a[1].to_f <=> b[1].to_f }

    #puts "scored videos = #{scored_videos}"

    sorted_videos.each do |scored|
      if scored[1] > toplist.min_score.to_f
        puts "adding #{scored[0]}"
        toplist.push scored[0], scored[1]
      end
    end


  end

  def self.videos_for_phrases(phrase_ids)
    videos_ids = []
    phrase_ids.each do |phrase_id|
      ids =  Phrase.video_ids_for(phrase_id)
      if ids.empty?
        Phrase.rebuild_index(phrase_id)
        ids =  Phrase.video_ids_for(phrase_id)
      end

      if videos_ids.empty?
        videos_ids << ids

      else
        videos_ids = videos_ids & ids
      end
      videos_ids.flatten!
    end #finded each
    videos_ids
  end


  def self.perform
    toplist = Toplist.new

    most_liked = Rating.most_liked

    most_liked.each do |liked|
      toplist.push liked.video_id, liked.score 
    end
  end


end


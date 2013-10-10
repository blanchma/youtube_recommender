require 'logger'

$my_log = Logger.new('log/stopwords.log', 'weekly')

total_video = Video.select("id").count

$my_log.info "---------------------- STOPWORDS ----------------------"
Stopwords.all.each do |sw|
  phrase = Phrase.find_by_text sw
  if phrase
    phrase.destroy
    $my_log.info "Destroy: #{phrase.text}, idf: #{phrase.idf}(#{phrase.videos_count * 100 / total_videos.to_f}) p_scores:#{phrase.phrase_scores.count}, videos: #{phrase.videos.size} "
  end
end


$my_log.info "---------------------- SHORTWORDS ----------------------"
phrases = Phrase.where("length(text) < 3")

phrases.each do |phrase|
  phrase.destroy
  $my_log.info "Destroy: #{phrase.text}, idf: #{phrase.idf}(#{phrase.videos_count * 100 / total_videos.to_f}) p_scores:#{phrase.phrase_scores.count}, videos: #{phrase.videos.size} "
end


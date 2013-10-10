class VideoSearchDebug

  attr_accessor :words, :loser_words, :stopwords,:phrases_ids, :time_to_find_phrases, :time_to_find_videos,
  :time_to_count_matches,   :total_time, :build_time, :suppressed_phrase_ids_for_loop, :top_video_for_loop,
  :time_to_score_videos_for_loop,  :top_videos, :phrases, :iterations

  def initialize
    @stopwords = []
    @loser_words = []
    @top_video_for_loop = {}
    @phrases = []
    @time_to_score_videos_for_loop = {}
    @top_videos = {}
    @suppressed_phrase_ids_for_loop= {}
    @top_video_for_loop = {}

  end

  def add_video_debug (vid, iteration, attributes)

    if @top_videos[vid].nil?
      @top_videos[vid] = VideoDebug.new(vid, iteration, attributes)
    else
      @top_videos[vid].data_for_loop(iteration, attributes)
    end

  end

  def selected_video (vid, loop)
    @top_videos[vid].selected_for_loop=loop
  end

  def build
    @phrases_ids.each do |phrase_id|
      @phrases << Phrase.find(phrase_id)
    end

    @top_videos.each_pair do |key, value|
      value.complete_data
    end

  end

  def as_json(options = {})      
      {:words => words, :loser_words => loser_words, :stopwords => stopwords, :phrases_ids => phrases_ids, :time_to_find_phrases => time_to_find_phrases, :time_to_find_videos => time_to_find_videos,
  :time_to_count_matches => time_to_count_matches , :total_time => total_time,
  :build_time => build_time, :top_video_for_loop => top_video_for_loop, :time_to_score_videos_for_loop => time_to_score_videos_for_loop,
  :top_videos => top_videos, :phrases => phrases, :loops => iterations}
  end

end


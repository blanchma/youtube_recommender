class VideoDebug

  attr_accessor :id, :title, :keywords, :description, :rating_score, :views_score, :user_score, :relevance,
  :suppressed_for_loop, :rarity_for_loop, :total_score_for_loop, :selected_for_loop

  def initialize(vid, iteration, attributes)
    @id = vid
    @selected_for_loop = -1
    @relevance = attributes[:relevance]
    @user_score = attributes[:video_score]

    @suppressed_for_loop = {}
    @rarity_for_loop = {}
    @total_score_for_loop = {}
    data_for_loop(iteration, attributes)
  end

  def data_for_loop(iteration, attributes)
    @suppressed_for_loop[iteration] = attributes[:suppressed]
    @rarity_for_loop[iteration]= attributes[:rarity]
    @total_score_for_loop[iteration]= attributes[:total_score]
  end


  def complete_data
    video = Video.find id
    @title = video.title
    @keywords = video.keywords
    @description = video.description
    @rating_score = video.rating_score
    @views_score = video.views_score
  end


  
  def as_json(options = {})
    super(:only => [:id, :title, :keywords, :description, :rating_score, :views_score, :video_score, :relevance,
    :suppressed_for_loop, :rarity_for_loop, :total_score_for_loop, :selected_for_loop])
  end

end


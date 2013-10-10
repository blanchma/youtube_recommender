class VideosController < ApplicationController
  respond_to :json

  def watch    
    render :template => "/player/show", :layout => "player"
  end

   def show
    @video = Video.find params[:id] 
    respond_with @video
  end

  def pop    
    video = Video.find params[:id]    
    render :inline => "<div><div class='float left'><img src='#{video.thumb_url}' width='106' heigh='89'> </div><div class='float middle'><p class='title'> #{video.title}</p><p class='author'>By: #{video.author}</p></div></div>"    
  end

  def destroy
    if Video.exists? params[:id]
      Video.destroy params[:id]
      Playlist.remove_video_from_all(params[:id])
      respond_with :text => true
    else
      respond_with :text => false
    end
  end

  def search
    query = params[:query]
    count = params[:count].to_i
    logger.info "Query(#{params[:count]})=#{query}"

    words = query.split(" ")

    if words.size > 10
      logger.info "Too much words(#{words.size}): words"
      flashMessage "Too much words"
      return
    end

    finded_phrase_ids = []
    time = Benchmark.realtime do
      words.each do |word|
        word.downcase
        is_a_stopword =  Stopwords.is?(word)

        next if is_a_stopword

        #phrases = Phrase.select("id, text").where("text = ?", word)
        phrases = Phrase.find_by_sql ["SELECT id, text FROM phrases WHERE text = ?", word]

        if phrases.size > 0
          phrases.each do |phrase|
            finded_phrase_ids << phrase.id
          end
        else
          phrase = Phrase.find_or_create_by_text(word)
          # search_debug.loser_words << word unless search_debug.nil? #DEBUG
          finded_phrase_ids << phrase.id
        end

      end
    end

    logger.info "Find the phrases in Mysql take #{time} secs"



    logger.info "Phrase ids:#{finded_phrase_ids} for #{query}"

    search = SphinxSearcher.find_or_create(current_user, finded_phrase_ids, query)

    if count > 2
      sleep 2
      video = search.find_a_video(true)
    else
      video = search.find_a_video(false)
    end

    current_user.add_to_screen_list video.id

    if video
      logger.info "[Controller] Video returned from search: #{video.title} (id=#{video.id})"
      render :json => [video]
    else
      logger.info "No more videos for query=#{query}"
      flashMessage "Not videos found" if count == 0
      render :text => false
    end

  end




end


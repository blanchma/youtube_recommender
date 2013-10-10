
class WelcomesController < ApplicationController
  before_filter :authenticate_user!, :except => [:redirect]


  def create
    weights = {"movies" => 3, "hobbies" => 3, "tv" => 3, "music" => 3}

    @hobbies = params[:hobbies]
    @music   = params[:music]
    @tv      = params[:tv]
    @movies  = params[:movies]

    [@hobbies, @music, @tv, @movies].each do |input|
      texts = input.split(/,\s*/)
      logger.info "About to add phrases: #{texts}"
      texts.each do |text|
        phrase = Phrase.find_or_create_by_text(text)
        if phrase.id
            ps = current_user.phrase_scores.find_or_create_by_phrase_id(phrase.id) 
            ps.likes = ps.likes + 3
            ps.save
        end
      end
    end
    if current_user.phrase_scores.count > 3
      logger.info "#{current_user.email} have phrases_scores  #{current_user.phrase_scores.count}"
      redirect_to player_path
    else
      flash[:notice]="Please, we need a few more interests from you"
      render :fill_phrases
    end
  end

  def fill_phrases

  end

  def redirect
    redirect_to player_path
  end

  def crawl_facebook

    unless current_user.fb_token.nil?

      fb = FbParser.new current_user.fb_token
      phrases = fb.snapshot

      phrases.each do |text, likes|
        text = text.dup
        phrase = Phrase.find_or_create_by_text(text)
        if phrase.id
            phrase_scores = current_user.phrase_scores.find_or_initialize_by_phrase_id(phrase.id)
            phrase_scores.likes = phrase_scores.likes + likes
            phrase_scores.save!
        end
      end
    end
    render :text => current_user. phrase_scores.count > 3
  end

end


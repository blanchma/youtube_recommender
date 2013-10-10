class PhraseScoresController < ApplicationController
  before_filter :authenticate_user!
  layout 'debug'

  def index
    #  current_user.update_phrase_cache_if_expired!

    @limited = true
    @phrases = current_user.phrase_scores.with_phrase.order('p_weighted_cache DESC').limit(500).sort_by(&:score).reverse
  end
end


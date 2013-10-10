require 'csv'

CSV.open("script/phrase_scores.csv", "w", {:force_quotes => true, :headers => :first_row} ) do |csv|

  csv << ["user_id", "text", "likes", "hates", "total", "p_like", "p_weight", "p_rare", "p_tanh", "p_unseen", "score"]

  PhraseScore.for_search.limit(1000).sort_by(&:score).each do |ps|

    csv << [ps.scoreable_id, ps.text, ps.likes, ps.hates, ps.total, ps.p_like, ps.p_weighted, ps.p_rare, ps.p_tanh, ps.p_unseen, ps.score]
    
  end
end


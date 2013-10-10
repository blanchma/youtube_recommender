#PhraseScore.where("likes=1 AND hates=0").find_in_batches(:batch_size => 1000) do |phrase_scores|
PhraseScore.find_in_batches(:batch_size => 1000) do |phrase_scores|
  phrase_scores.each do |phrase_score|

    phrase_score.save
  end

end




def denormalize_phrases(user)
  user.phrase_scores.each do |phrase_score|
    # next if phrase_score.phrase_id
    phrase = Phrase.where(:text => phrase_score.text).first
    
    unless phrase
      if phrase_score.voted?
        puts "No phrase for #{phrase_score.text}...I will make one."
        phrase = Phrase.create(:text => phrase_score.text, :videos_count => 0, :idf => 0)
      else
        puts "Destroying nonvoted: #{phrase_score.text}"
        phrase_score.destroy
        next
      end
    end
    
    phrase_score.update_attribute(:phrase_id, phrase.id)
  end
  true
end


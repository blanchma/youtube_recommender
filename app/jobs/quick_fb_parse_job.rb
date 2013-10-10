require 'cron_logger'

class QuickFbParsejob
  @queue = :critical


  def self.perform (user)
    fb_parser = FbParser.new(user.fb_token)

       
    phrases = fb_parser.picture #friends, important post
    save_phrases (phrases)
    user.playlist.try_to_improve    
    
    phrases = fb_parser.rake
    save_phrases (phrases)
    user.playlist.try_to_improve    
    
  end

  def save_phrases
    phrases.each do |text, likes|
      text = text.dup
      phrase = Phrase.find_or_create_by_text(text)
      ps = current_user.phrase_scores.find_or_initialize_by_phrase_id(phrase.id)
      ps.likes = ps.likes + likes
      ps.save!
    end

  end

end


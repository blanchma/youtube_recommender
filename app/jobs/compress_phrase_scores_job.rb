class CompressPhraseScoresJob
    @queue = :low

  def self.perform(recently=true)
       puts "Compressing Phrase Scores..."
       to_compress = PhraseScore.recently 
       to_compress = PhraseScore.select("DISTINCT scoreable_id, scoreable_type") unless recently
        to_compress.each do |recent|
          next unless recent.scoreable
          PhraseScore.compress(recent.scoreable)
         end
  end
  
end

     


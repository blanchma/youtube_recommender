batches = (Phrase.count/1000)+1
i = 0
time = Time.now
Phrase.find_in_batches do |phrases|
  i = i+1
  diff = Time.now - time
  time = Time.now
  puts "Batch #{i} of #{batches}...(last took #{diff} seconds)"
  phrases.each do |phrase|
    old_count = phrase.videos_count
    phrase.update_videos_count
    unless (phrase.videos_count == old_count)
      # puts "saving #{phrase.text}"
      phrase.save
    end
  end
end;true
puts "ALL DONE"
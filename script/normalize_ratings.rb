 Rating.where("action = ?", "skipped").find_in_batches(:batch_size => 1000) do |ratings|
  ratings.each do |rating|
      rating.action="watched"
      rating.save
    end
 end
 
Rating.find_in_batches(:batch_size => 1000) do |ratings|
  ratings.each do |rating|
    group= Rating.where({:user_id => rating.user_id, :video_id => rating.video_id})
    
    if group.size > 1
        group.first(group.size - 1).each do |member|
          member.destroy
        end
     
    end
    
  end
  
end
 
 

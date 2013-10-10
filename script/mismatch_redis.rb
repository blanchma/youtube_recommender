User.all.each do |u|
  puts ""
  puts "USER: #{u.email}"
  u.phrase_scores(true).each do |ps|
    unless ps.redis_score == ps.p_weighted
      diff = (ps.redis_score - ps.p_weighted).abs
      if diff > 0.01
        puts "#{ps.id} off by (#{diff}) (#{ps.p_weighted} != r:#{ps.redis_score}) -> #{ps.text}, phrase_id: #{ps.phrase_id}"
        ps.update_redis
      end
    end
  end; true
  puts ""
  puts ""
end;true
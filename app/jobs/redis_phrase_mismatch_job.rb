require "benchmark"
require "cron_logger"

class RedisPhraseMismatchJob
  @queue = :low

  def self.perform
    $logger.info "#{Time.now}: RedisPhraseMismatchJob begin"
    time = Benchmark.realtime do
      User.all.each do |user|
        check_scores_for(user)
      end
    end
    $cron.info "#{Time.now}: RedisPhraseMismatchJob end in #{time} ms"
  end

  def self.check_scores_for(user)
    failures = false
    user.phrase_scores(true).each do |ps|
      unless ps.redis_score == ps.p_weighted
        diff = (ps.redis_score - ps.p_weighted).abs
        if diff > 0.01
          failures = true
          if ps.dupe?
            user = ps.user
            dupes = user.phrase_scores.where(:phrase_id => ps.phrase_id).order('created_at')
            keeper = dupes.pop
            dupes.each {|dupe| dupe.destroy}
            ps = keeper
          end
          ps.update_redis
        end
      end
    end
    failures
  end

end


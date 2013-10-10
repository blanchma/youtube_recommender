class CategoryScore < ActiveRecord::Base
  belongs_to :scoreable, :polymorphic => true
  belongs_to :category

  before_save :calculate!

  def calculate!
    total = likes + hates
    base = ("1" + "0" * (total.to_s.length - 1) ) .to_i
    if total > 1      
      self.score = (likes / total.to_f) - (0.2 / base).to_f
    else
      self.score =  0.5
    end
    self.score
  end

  def update_redis!
    REDIS.hset "scores:#{scoreable_type}-#{scoreable_id}:categories:", category_id, self.score
  end

  def self.add(subject, rating)
        cat_rate = subject.category_scores.find_or_create_by_category_id rating.video.category_id
        cat_rate.likes += 1 if rating.liked?
        cat_rate.hates += 1 if rating.hated?
        cat_rate.save
  end
  
  def self.score_for(subject, category_id)
    score = REDIS.hget "scores:#{subject.class.name}-#{subject.id}:categories", category_id

    unless score
      category_score =  subject.category_scores.find_by_category_id category_id
      score = 0.5
      if category_score
        score = category_score.score 
        category_score.update_redis! 
      end
    end
    score
  end


end


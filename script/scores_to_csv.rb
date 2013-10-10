require 'csv'

CSV.open("script/video_scores.csv", "w", {:force_quotes => true, :headers => :first_row} ) do |csv|

  csv << ["video_id", "user_id", "action", "avg_phrase_score +","views_score +", "rating_score + ", "category", "category_score + ", "tota_score"]

  Rating.order("video_id ASC").find_in_batches do |ratings|

    ratings.each do |rating|

      unless rating.video.nil?
        vid = rating.video.id
        next unless rating.user
        user_id = rating.user.id
        avg_score= rating.user.get_avg_phrase_score_for vid
        score_video = rating.user.score_for_video vid
        next unless score_video.to_f > 0
        views_score = rating.video.views_score
        rating_score = rating.video.rating_score
        category_score = rating.user.get_category_score vid 
        category = rating.video.categories
        action = rating.action
        csv << [vid, user_id, action, avg_score, views_score, rating_score, category, category_score, score_video]
      end

    end

  end
end


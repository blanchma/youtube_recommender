
# def write_user_x
#   video_count = Video.count
#   i = 0
#   puts "loading users"
#   users = YoutubeUser.order('id')
#   CSV.open('/home/ytcrawler/favorites.csv','w') do |csv|
#     puts "adding header..."
#     csv << [' '].concat(users.collect(&:username))
#     Video.find_in_batches do |videos|
#       videos.each do |video|
#         i = i+1
#         puts "v: #{video.id} / ##{i} of #{video_count}"
#         favorited_by_ids = video.youtube_users.all(:select => 'id').collect(&:id)
#         csv << users.collect do |user|
#           if favorited_by_ids.include?(user.id)
#             1
#           else
#             0
#           end
#         end
#       end
#     end
#   end
# end

def write_words_videos
  phrase_count = Phrase.count
  video_count  = Video.count
  i = 0
  batches = (video_count/1000)+1
  
  puts "loading all phrases"
  phrases = Phrase.select('id, text')
  phrase_ids = phrases.collect(&:id)
  CSV.open('phrases_videos.csv','w') do |csv|
    puts "writing video id header"
    csv << ['phrase:'].concat(phrases.collect(&:text))
    Video.find_in_batches do |videos|
      break if i > 1
      i = i+1
      time = Time.now
      puts "Processing batch #{i} of #{batches}"
      videos.each do |video|
        # the left-most column of video_ids
        row = [video.id]
        video_phrase_ids = video.phrase_ids
        phrase_ids.each do |phrase_id|
          if video_phrase_ids.include?(phrase_id)
            puts "#{video.id} has #{phrase_id}"
            # this phrase is in the video
            row << 1
          else
            row << 0
          end
        end
        csv << row
      end
    end
    diff = Time.now - time
    puts "...took #{diff} seconds"
  end
end

def video_id_and_title
  CSV.open('video_titles.csv','w') do |csv|
    i = 0
    batches = (Video.count/1000)+1
    Video.find_in_batches do |videos|
      i = i+1
      puts "batch #{i}/#{batches}"
      videos.each do |video|
        csv << [video.id, video.title]
      end
    end
  end
end

def write_user_y
  user_count = YoutubeUser.count
  i = 0
  video_ids = Video.all(:select => 'id').collect(&:id)
  CSV.open('~/favorites.csv','w') do |csv|
    puts "adding header..."
    csv << ["username:"].concat(video_ids)
    YoutubeUser.find_in_batches do |users|
      # YoutubeUser.where(:username => "mamshmam").each do |user|
      users.each do |user|
        i = i + 1
        puts "user: #{user.username} [#{i}/#{user_count}]"
        likes = [user.username]
        user_favorite_ids = user.videos.collect(&:id)
        # puts "favs: #{user_favorite_ids}"
        video_ids.each do |video_id|
          if user_favorite_ids.include?(video_id)
            # puts "likes: #{video_id}"
            likes << 1
          else
            likes << 0
          end
        end
        csv << likes
      end
    end # batched
  end
end

require 'csv'
def write_mtv_user_x(users)
  video_ids = Video.all(:select => 'id').collect(&:id)
  CSV.open('mynewtv_users.csv','w') do |csv|
    csv << ["username:"].concat(video_ids)
    users.each do |user|
      liked_ids = user.ratings.liked.select('video_id').collect(&:video_id)
      hated_ids = user.ratings.hated.select('video_id').collect(&:video_id)

      row = [user.email]
      video_ids.each do |video_id|
        if liked_ids.include?(video_id)
          puts "liked id: #{video_id}"
          row << 1
        elsif hated_ids.include?(video_id)
          puts "hated id: #{video_id}"
          row << -1
        else
          row << 0
        end
      end
      csv << row
    end
  end
end

def write_mtv_user_y(user)
  video_ids = Video.all(:select => 'id').collect(&:id)
  CSV.open('mynewtv_user.csv','w') do |csv|
    csv << ['video_id', user.email]
    
    liked_ids = user.ratings.liked.select('video_id').collect(&:video_id)
    hated_ids = user.ratings.hated.select('video_id').collect(&:video_id)

    video_ids.each do |video_id|
      if liked_ids.include?(video_id)
        csv << [video_id, 1]
      elsif hated_ids.include?(video_id)
        csv << [video_id, -1]
      else
        csv << [video_id, 0]
      end
    end
  end
end


def multi
  multis = []
  Video.find_in_batches do |videos|
    videos.each do |video|
      if video.youtube_users.count > 1
        multis << video.id
      end
    end
  end
end

def video_ids
  CSV.open('video_ids.csv', 'w') do |csv|
  Video.find_in_batches(:select => 'id') do |videos|
    videos.each do |video|
      csv << [video.id]
    end
  end
end
    

# u = YoutubeUser.where(:username => 'mamshmam').first
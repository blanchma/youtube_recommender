# require 'redis'
require
$redis = Redis.new(:db => 1)


def go
  i = 0
 
  
  Video.find_in_batches do |videos|
    i += 1
    diff = Time.now - time
    time = Time.now
    puts "Batch #{i} of #{total} - #{diff} seconds since last..."
    
    videos.each do |v|
      # puts "id #{v.id}: #{v.words_ary.size} words."
      v.words_ary.each do |word|
        add_video_to_word(word, v.id)
      end
    end
  end
end

  

def save_word(word)
  id        = $redis.hget('words:ids',word)
  size      = $redis.get(words_video_list_size_key(word)).to_i
  video_ids = $redis.smembers(words_video_list_key(word))
  Phrase.transaction do
    begin
      sql = Phrase.send(:sanitize_sql, ["INSERT INTO phrases (id, text, idf, videos_count) VALUES (?, ?, 1, ?)", id, word, size])
      id = Phrase.connection.insert_sql(sql)
    rescue Encoding::CompatibilityError => e
      puts "ENCODING BULLSHIT ERROR!: #{e.inspect}"
      puts "We are skipping word id: #{id} text: #{word}"
      return false
    rescue ActiveRecord::RecordNotUnique => e
      id_sql = Phrase.send(:sanitize_sql, ["SELECT id FROM phrases WHERE text=?", word])
      id = Phrase.connection.select_value(id_sql)
      if id
        id = id.to_i
      else
        puts "\t\tWord id:#{id}, text: #{word}, count:#{size} error, not unique!"
        puts "\t\t*** !!! NO ANALOG FOUND FOR #{word}! SHIT!"
      end
    end
  
    video_ids.each do |video_id|
      sql = "INSERT INTO phrases_videos (phrase_id, video_id) VALUES (#{id},#{video_id})"
      Phrase.connection.insert_sql(sql)
    end
  end
  true
end

def save_to_mysql
  total = $redis.llen('words')
  batches = (total.to_i / 10000) + 1
  i = 0
  batch = 0
  time = Time.now
  while word = $redis.lpop('words')
    begin
      
      if (i % 10000 == 0)
        batch += 1
        diff = Time.now - time
        time = Time.now
        puts "Starting batch #{batch} of approximately #{batches} - #{diff} seconds since last."
      end
      i += 1

      save_word(word)
    rescue Exception => e
      puts "Something went wrong, adding #{word} to beginning of wordlist..."
      $redis.rpush('words', word)
      raise e
    end
  end
end

def go_idf
  i = 0
  total_words = $redis.hlen('words:ids')
  $redis.hkeys('words:ids').each do |word|
    i = i + 1
    if (i % 10000 == 0)
      puts "About to do word #{i} of #{total_words}"
    end
    size = $redis.smembers(words_video_list_key(word)).size
    # idf  = Math.log(total_videos.to_f/size)    
    $redis.set(words_video_list_size_key(word), size)
    # $redis.set(words_idf_key(word), idf)
  end
  true
end

def go_wordlist
  i = 0
  batch = 0
  batches = ($redis.hlen('words:ids').to_i / 10000) + 1
  time = Time.now
  $redis.hkeys('words:ids').each do |word|
    i += 1
    if (i % 10000 == 0)
      batch += 1
      diff = Time.now - time
      time = Time.now
      puts "Batch #{batch} of #{batches} - #{diff} seconds since last batch..."
    end
    $redis.rpush('words',word)
  end
  true
end

def add_video_to_word(word, video_id)
  key = words_video_list_key(word)
  # puts "#{word} (#{key}) -> #{video_id}"
  $redis.sadd(key, video_id)
end

def words_video_list_key(word)
  id = get_unique_id(word)
  "words:#{id}:videos"
end

def words_video_list_size_key(word)
  id = get_unique_id(word)
  "words:#{id}:videos.size"
end

def words_idf_key(word)
  id = get_unique_id(word)
  "word:#{id}:idf"
end


def get_unique_id(word)
  id = $redis.hget('words:ids',word)
  return id.to_i if id
  
  id = $redis.incr('words:next.id')
  
  $redis.hset('words:ids', word, id)
  
  id.to_i
end
# def get_unique_id(object,token)
#     md5 = Digest::MD5.hexdigest(token)
#     id = $redis.get("#{object}:#{md5}:id")
#     return id.to_i if id
#     id = $redis.incr("#{object}:next.id")
#     $redis.set("#{object}:#{id}:string",token)
#     if !$redis.setnx("#{object}:#{md5}:id",id)
#         # Someone added the new token faster than us.
#         $redis.del("#{object}:#{id}:string")
#         get_unique_id(object,token)
#     else
#         id.to_i
#     end
# end


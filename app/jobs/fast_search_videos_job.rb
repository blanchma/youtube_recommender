class FastSearchVideosJob
  @queue = :critical

  def self.perform(query,id,redis=true)
    if redis
      performRedis(query,id)
    else
      performSphinx(query,id)
    end
  end

  def self.performSphinx (query, id)
    begin
      yc = YoutubeCrawler.new
      puts "#{Time.now}: FastSearchVideosJob for #{query}"
      yc.crawl_phrase(query, 1, 10)

    rescue Exception => e
      puts "Exception caught: #{e.inspect}"
      #  puts e.backtrace
      tries ||= 1
      if tries < 3
        tries += 1
        puts "Retrying FastSearchVideosJob for #{query}"
        retry
      end
    end
  end


def self.performRedis (query, id)
  begin
    yc = YoutubeCrawler.new
    puts "#{Time.now}: FastSearchVideosJob for #{query}"
    #(text, start_page=1, max_page=40, max_results=25)
    page =1
    crawl = true
    time = Benchmark.realtime do
      while (crawl)
        videos,crawl = yc.crawl_query(query, page, 10)

        crawl=false unless videos

        REDIS.pipelined do
          videos.each do |vid|
            puts "[Job] new_vid = #{vid.id}"
            REDIS.sadd "search:#{id}:svids", vid.id
          end
        end

        crawl=false
      end
    end#Benchmark
    puts "End FastSearchVideosJob for #{query} in #{time} secs"

  rescue Exception => e
    puts "Exception caught: #{e.inspect}"
    #  puts e.backtrace
    tries ||= 1
    if tries < 3
      tries += 1
      puts "Retrying FastSearchVideosJob for #{query}"
      retry
    end
  end
end
end


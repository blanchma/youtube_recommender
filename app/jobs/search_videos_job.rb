

class SearchVideosJob
  @queue = :critical

  def self.perform (query, id)

    begin
      yc = YoutubeCrawler.new
      puts "#{Time.now}: SearchVideosJob for #{query}"
      #(text, start_page=1, max_page=40, max_results=25)
      page =1
      crawl = true
      time = Benchmark.realtime do
        while (crawl)
          videos, crawl = yc.crawl_query(query, page, 5)
            
          crawl=false unless videos

          REDIS.pipelined do
            videos.each do |vid|
              REDIS.sadd "search:#{id}:svids", vid.id
            end
          end
          page+=1
          crawl=false if page > 5
        end
      end#Benchmark
      puts "End SearchVideosJob for #{query} in #{time} secs"

    rescue Exception => e
      puts "Exception caught: #{e.inspect} \n #{e.backstrace}"
      #  puts e.backtrace
      tries ||= 1
      if tries < 3
        tries += 1
        puts "Retrying SearchVideosJob for #{query}"
        retry
      end
    end
  end
end




class CrawlDailyJob
  @queue = :low

  def self.perform

    time = Benchmark.realtime do
      yc = YoutubeCrawler.new
      begin
        yc.crawl_today
      rescue Exception => e
        puts "Exception caught: #{e.inspect}"
        #  puts e.backtrace
        tries ||= 1
        if tries < 5
          tries += 1
          puts "Retrying!"
          retry
        else
          puts "Failed too many times! I'm done!"
          # forget it, let it go
          # raise e
        end
      end
    end
    puts "CrawlDailyJob takes #{time.to_i} secs"

  end
end


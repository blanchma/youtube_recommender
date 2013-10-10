require 'cron_logger.rb'

class CrawlPhrasesJob
  @queue = :medium

  def self.perform(phrase_ids)
    puts "#{Time.now}: CrawlPhrasesJob begin"
    time = Benchmark.realtime do
      # convert to array if it's a bare id
      phrase_ids = [phrase_ids] if phrase_ids.is_a?(Integer)
      phrases = Phrase.find(phrase_ids)

      phrases.each do |phrase|
        crawl_phrase(phrase)
      end
    end
    puts "CrawlPhrasesJob end in #{time} seconds"
  end

  def self.crawl_phrase(phrase)
    if phrase.recently_crawled?
      puts "#{Time.now}: #{phrase.text} (id:#{phrase.id}) crawled recently (#{phrase.last_crawled_at.to_s(:short)}), skipping."
    else
      yc = YoutubeCrawler.new
      page = phrase.last_crawled_page.nil? ? 1 : phrase.last_crawled_page + 1
      puts "Crawling phrase #{phrase.text}, starting page #{page}"
      begin
        last_crawled_page = yc.crawl_phrase(:text => phrase.text, :start_page => page, :max_page => page +1, :max_results => 15)
      rescue Exception => e
        puts "#{Time.now}: Exception caught: #{e.inspect}"
        tries ||= 1
        if tries < 5
          tries += 1
          puts "Retrying!"
          retry
        else
          # forget it, let it go
          # raise e
        end
      end
      phrase.update_attributes!(:last_crawled_page => last_crawled_page, :last_crawled_at => Time.now)
      puts "#{Time.now}: #{phrase.text} crawled #{last_crawled_page} page successfully"
    end
  end
end


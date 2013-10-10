

class CrawlLikedPhraseJob
  @queue = :medium

  def self.perform(phrasearg)
    puts "#{Time.now}: CrawlLikedPhraseJob begin for '#{phrasearg}'"
    phrase = ""
    time = Benchmark.realtime do
      # convert to array if it's a bare id
      if phrasearg.is_a? (Integer)
        phrase = Phrase.find phrasearg
      else
        phrase = Phrase.find_or_create_by_text phrasearg
      end
      unless phrase.nil?
        crawl_phrase(phrase)
      end

      puts "#{Time.now}: CrawlLikedPhraseJob for #{phrase.text} end in (#{time} seconds)"
    end


  end

  def self.crawl_phrase(phrase)

    if phrase.recently_crawled?
      puts "#{Time.now}: liked phrase: #{phrase.text} (id:#{phrase.id}) crawled recently (#{phrase.last_crawled_at.to_s(:short)}), skipping."
    else
      yc = YoutubeCrawler.new
      puts "Crawling liked phrase #{phrase.text}"
      begin
        yc.crawl_phrase(phrase.text, 1, 2, 5)
      rescue Exception => e
        puts "#{Time.now}: Exception caught: #{e.inspect}"
        tries ||= 1
        if tries < 3
          tries += 1
          puts "#{Time.now}: Retrying crawling liked phrase!"
          retry
        else
          # forget it, let it go
          # raise e
        end
      end
      phrase.update_attributes!(:last_crawled_page => 1, :last_crawled_at => Time.now)
      puts "#{Time.now}: liked phrase: #{phrase.text} crawled successfully"
    end
  end
end


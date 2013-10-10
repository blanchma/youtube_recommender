require 'cron_logger'

class CrawlMostLikedPhrasesJob
  @queue = :medium

  def self.perform(user_id=nil)
    puts "#{Time.now}: CrawlMostLikedPhrasesJob begin"
    @phrases_sended_to_crawl = []
    @users = nil
    time = Benchmark.realtime do
      
      if user_id
        user = User.find user_id
        phrases = user.phrase_scores.order("likes DESC").joins(:phrase).limit(5) & Phrase.to_crawl
        @phrases_sended_to_crawl << phrases
        phrases.each do |phrase|
          puts "#{Time.now}: Sending to Crawl Liked Phrase: #{phrase.text} "
          #Resque.enqueue(CrawlLikedPhraseJob, phrase.text)
          CrawlLikedPhraseJob.perform phrase.text
        end #phrases

        user.update_attributes!(:crawled_at => Time.now)
        
    else
      @users = User.to_crawl.limit(30)
      @users.each do |user|
        puts "#{Time.now}: Crawling #{user.email} for liked phrase"
        phrases = user.phrase_scores.order("likes DESC").joins(:phrase).limit(5) & Phrase.to_crawl
        @phrases_sended_to_crawl << phrases
        phrases.each do |phrase|
          puts "#{Time.now}: Sending to Crawl Liked Phrase: #{phrase.text} "
          #Resque.enqueue(CrawlLikedPhraseJob, phrase.text)
          CrawlLikedPhraseJob.perform phrase.text
        end #phrases

        user.update_attributes!(:crawled_at => Time.now)


      end #users
    end
      @phrases_sended_to_crawl.flatten!
    end #benchmark
    puts "#{Time.now}: CrawlMostLikedPhrasesJob: #{@phrases_sended_to_crawl.size} phrases end in #{time} seconds"
  end


end


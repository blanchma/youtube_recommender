#require 'youtube_it'

class YoutubeCrawler

  API_KEY="AI39si4HpMGYbinAOUk049XCy_LvoQZSJhJh1lhTQrMiHFDZ7b78LDnoCKWVgnuAYIcJsI4M-IwOkRIJRMLhb2s-psYv31zlMA"

  def client
    @client ||= YouTubeG::Client.new#(:dev_key => API_KEY)
  end



  def crawl_query(query, page, max_results)
    crawling = true

    puts "Crawling for #{query}, page #{page}"
    results = client.videos_by(:query => query, :page => page, :max_results => max_results, :format => 5)

    new_videos = create_videos(results.videos)

    Rails.logger.info "[Crawler] #{new_videos.size} videos created in page:#{page} for query:#{query}"
    unless results.next_page
      return new_videos,false
    end

    return new_videos,true
  end


  def crawl_phrase(text, start_page=1, max_page=40, max_results=25)
    page = start_page
    crawling = true
    while crawling
      begin
        puts "Crawling for #{text}, page #{page}"
        results = client.videos_by(:query => text, :page => page, :max_results => max_results, :format => 5)

        create_videos(results.videos)

        page += 1

        unless results.next_page
          crawling = false
        end
        if page > max_page
          crawling = false
        end

      rescue OpenURI::HTTPError => e
        puts "Caught HTTPError, stopping: #{e.inspect}"
        crawling = false
      end
    end
    # return the last page we successfully crawled
    #   puts "Crawled #{new_videos} for phrase #{text}"
    return page-1
  end

  def crawl_today
    total = 0
    total += crawl_most_viewed
    total += crawl_most_linked
    total += crawl_top_rated
    total += crawl_top_favorites
    puts "TOTAL DAILY CRAWL: #{total}"
  end

  def crawl_top_favorites
    crawl_special(:top_favorites)
  end

  def crawl_most_viewed
    crawl_special(:most_viewed)
  end

  def crawl_most_linked
    crawl_special(:most_linked)
  end

  def crawl_most_popular
    crawl_special(:most_popular)
  end

  def crawl_top_rated
    crawl_special(:top_rated)
  end

  def crawl_special(key=:most_viewed)
    total = 0
    page=1
    crawling = true
    puts "Crawling for #{key}"
    while crawling
      begin
        results = client.videos_by(key, :time => :today, :page => page, :max_results => 10, :format => 5)

        total += create_videos(results.videos).size
        crawling = false unless results.next_page
        page = results.next_page
    rescue OpenURI::HTTPError => e
        puts "Error crawling #{key} -> #{e.inspect}"
        crawling = false
      end
      
    end
    total
  end

  def crawl_usernames(limit=10)
    crawled = 0
    while usernames_to_crawl_size > 0 && crawled < limit
      begin
        u = next_username
        crawl_username(u)
        crawled += 1
      rescue OpenURI::HTTPError => e
        puts "ERROR CRAWLING FOR #{u}: #{e.inspect}"
        next
      end
    end
  end

  def create_videos(youtube_videos)
    time = Benchmark.realtime do
      ids         = youtube_videos.collect(&:unique_id)
      found_ids   = Video.where(:youtube_id => ids).collect(&:youtube_id)

      # skip the ones we already have
      youtube_videos.reject! { |v| found_ids.include?(v.unique_id) }

    end
    puts "Check repeated id take #{time.to_i} secs"



    new_videos = youtube_videos.collect do |youtube_video|
      vid = youtube_video.to_mynewtv_video
      if vid
        vid.save ? vid : nil
      else
        nil
      end
    end

    puts "Create #{new_videos.size} new videos"
    new_videos.compact!
   
    new_videos
  end

  def find_or_create_videos(youtube_videos)
    ids         = youtube_videos.collect(&:unique_id)
    found       = Video.where(:youtube_id => ids)
    found_ids   = found.collect(&:youtube_id)

    # skip the ones we already have
    youtube_videos.reject! { |v| found_ids.include?(v.unique_id) }

    # convert youtube vids to database records
    missing = youtube_videos.collect do |youtube_video|
      vid = youtube_video.to_mynewtv_video
      if vid
        add_usernames_to_crawl([vid.author])
        vid.save ? vid : nil
      else
        return nil
      end
    end

    # remove any records that didn't save
    missing.compact!

    found + missing
  end

  def crawl_video(youtube_id)
    return nil if Video.where(:youtube_id => youtube_id).exists?
    ytvid = client.video_by(youtube_id)
    videos = find_or_create_videos([ytvid])
  end

end


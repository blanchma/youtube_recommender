require 'cron_logger'

class SearchCleanupJob
  @queue = :low

  def self.perform
    $cron.info "#{Time.now}: SearchCleanupJob begin"
    puts "SearchCleanupJobbegin"
    count = 0
    time = Benchmark.realtime do
      keys = REDIS.keys "user:*:pids:*"
      puts "keys to hose: #{keys.size}"
      keys.each_slice(100) do |slice|

        slice.each do |key|
          id = REDIS.get "#{key}"
    
          if Searcher.destroy(id)
            count+=1            
            REDIS.pipelined do
                REDIS.del key
            end
          end
        end

      end
    end
    puts "No more Search Trash. Removed #{count} keys"
    puts "#{Time.now}: SearchCleanupJobend in #{time} ms"
    $cron.info "#{Time.now}: SearchCleanupJob end in #{time} ms"
  end
end


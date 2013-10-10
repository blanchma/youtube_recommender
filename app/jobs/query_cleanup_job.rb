require 'cron_logger'

class QueryCleanupJob
  @queue = :low

  def self.perform
    $cron.info "#{Time.now}: QueryCleanupJob begin"
      puts "QueryCleanupJob begin"
    time = Benchmark.realtime do
      keys = REDIS.keys 'query:*'
      puts "keys to hose: #{keys.size}"
      keys.each_slice(10000) do |slice|
        REDIS.pipelined do
          slice.each {|k| REDIS.del k}
        end
      end
      puts "clean as a whistle"
    end
    puts "#{Time.now}: QueryCleanupJob end in #{time} ms"
    $cron.info "#{Time.now}: QueryCleanupJob end in #{time} ms"
  end
end


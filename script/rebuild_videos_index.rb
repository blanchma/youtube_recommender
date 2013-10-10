
unless ARGV[0].nil?
  id_min = ARGV[0]
else
  id_min = 0
end



def logger (msg)
  puts msg
end


logger "#{Time.now}: Fix Video Inconsistencies begin"
total = Video.count

time = Benchmark.realtime do

  logger "Videos to check #{total}"


  Video.where("id > ?", id_min).find_in_batches(:batch_size => 1000) do |videos|
    sleep 5
    videos.each do |vid|
      REDIS.pipelined do        
          REDIS.set "video:#{vid.id}:rating_score", vid.rating_score       
          REDIS.set "video:#{vid.id}:views_score", vid.views_score
      end
   
    
        logger "[#{vid.id}] Fixed"
    end #video.each

  end #video batch

end #benchmark
logger "#{Time.now}: Take (#{time/60} mins) to finish"


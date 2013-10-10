require 'logger'

$benchmark = Logger.new('log/benchmark.log', 'weekly')
$benchmark.datetime_format = "%Y-%m-%d %H:%M:%S"

def timer(desc)
  time = Benchmark.realtime { yield }
  $benchmark.info desc + " (#{time} ms)"
  #puts desc + " (#{time  * 1000} ms)"
end




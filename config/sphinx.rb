

rails_env   = ENV['RAILS_ENV']  || "production"
rails_root  = ENV['RAILS_ROOT'] || "/home/mynewtv2/current"


God.watch do |w|

  w.name  = "mynewtv-sphinx"

  w.interval = 30.seconds

  w.uid = "mynewtv-sphinx-uid"
  w.gid = "mynewtv-sphinx-gid"

  w.start         = "cd #{rails_root} && rake ts:start"
  w.start_grace   = 10.seconds  
  w.stop          = "cd #{rails_root} && rake ts:stop"
  w.stop_grace    = 10.seconds  
  w.restart       = "cd #{rails_root} && rake ts:rebuild"
  w.restart_grace = 15.seconds

  w.pid_file = "/home/mynewtv2/shared/searchd.pid"

  w.behavior(:clean_pid_file)

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval  = 5.seconds
      c.running   = false
    end
  end

  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 500.megabytes
      c.times = [3, 5] # 3 out of 5 intervals
    end
  end

  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state      = [:start, :restart]
      c.times         = 5
      c.within        = 5.minutes
      c.transition    = :unmonitored
      c.retry_in      = 10.minutes
      c.retry_times   = 5
      c.retry_within  = 2.hours
    end
  end
end

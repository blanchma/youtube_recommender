

bad_keys = REDIS.keys "phrase:*:video"

bad_keys.each_slice (500) do |slice|
  REDIS.pipelined do
    slice.each do |key|
      REDIS.renamenx key, (key+"s")
    end
  end

end



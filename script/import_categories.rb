Video.where("category_id is NULL").find_in_batches(:batch_size => 1000) do |videos|
  sleep 1
  videos.each do |vid|
    cat = Category.find_or_create_by_name vid.categories
    vid.category = cat
    REDIS.set "video:#{vid.id}:category", cat.id
    vid.save
    puts "video #{vid.id} with cat: #{cat.name}"
  end

end


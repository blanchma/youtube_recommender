class Stopwords

  def include? word
    REDIS.sismember "stopwords", word
  end

  def self.is? (word)
    REDIS.sismember "stopwords", word
  end

  def self.add word
    REDIS.sadd "stopwords", word
  end

  def self.remove word
    REDIS.srem "stopwords", word
  end

  def self.all
    REDIS.smembers "stopwords"
  end

end


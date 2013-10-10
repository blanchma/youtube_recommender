class FbParser
  attr_accessor :access_token
  attr_accessor :phrases
  attr_accessor :ids_processed

  def initialize(access_token)
    self.access_token = access_token

    self.phrases       = Hash.new(0)
    self.ids_processed = []
  end

  def pretty_print
    self.phrases
  end

  def enough_phrases?
    phrases.keys.size > 50
  end

  def parse_add_text(text, amount=1)
    parsed = parse(text).split(/\s+/)
    parsed.compact!
    parsed.reject! {|p| Stopwords.is?(p)}
    parsed.each {|p| phrases[p] += amount}
  end

  def add_text(text, amount=1)
    return false unless text && !text.empty?
    text.downcase!
    text.gsub!(/[.-]/, '\s')
    text = text.mb_chars.decompose.scan(/[a-zA-Z0-9\s+]/).join
    
    phrases[text] += amount
        
    parsed = parse(text).split(/\s+/)
    parsed.compact!
    parsed.reject! {|p| Stopwords.is?(p)}
    parsed.reject! {|p| phrases.keys.include? p }
    parsed.each {|p| phrases[p] += 1}
    
  end

  def parse(text)
    text ||= ''
    text.downcase!

    # remove obvious URLs with DF's regex:
    # http://daringfireball.net/2009/11/liberal_regex_for_matching_urls
    text.gsub!(/\b(([\w-]+:\/\/?|www[.])[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|\/)))/, '')

    # slashes to spaces
    text.gsub!(/(\w)\/(\w)/, '\1 \2')
   

    # strip meaningles leading & trailing punctuation
    text.gsub!(/^[^A-Za-z0-9]*/, '')
    text.gsub!(/[^A-Za-z0-9]*$/, '')

    # strip extra spaces
    text.gsub!(/\s+/,' ')

    text
  end

  #---------------------
  # FB stuff
  #---------------------
  def phrases_from_facebook_id(id='me')
    profile = MiniFB.get(access_token, id, :metadata=>true)

    [:name, :last_name, :website].each do |k|
      add_text profile.send(k), 1
    end

    if profile.has_key?('hometown')
      parse_add_text profile.hometown.name
    end

    if profile.has_key?('location')
      parse_add_text profile.location.name
    end

    if profile.has_key?('education')
      profile.education.collect {|entry| entry.school.name}.each do |school|
        add_text school, 1
      end
    end

    if profile.has_key?('work')
      profile.work.collect {|entry| entry.employer.name}.each do |employer|
        add_text employer, 1
      end
    end

    # feed name => text_fields
    feeds_to_parse = {
      'groups'    => [:name],
      'statuses'  => [:message],
      'events'    => [:name, :location],
      'links'     => [:name],
      'posts'     => [:name, :message],
      'albums'    => [:name],
    }

    feeds_to_not_parse = {
      'likes'     => [:name],
      'interests' => [:name],
      'books'     => [:name],
    }

    feeds_to_not_parse.each do |type, text_fields|
      puts "feed: #{type}"
      phrases = phrases_for_facebook_feed('me', type, text_fields)
      # puts "phrases: #{phrases.inspect}"
      phrases.each {|p| add_text p, 4}
    end

    unless enough_phrases?
      puts "Not enough phrases yet, looking at some of the more random text..."
      feeds_to_parse.each do |type, text_fields|
        puts "feed: #{type}"
        phrases = phrases_for_facebook_feed('me', type, text_fields)
        puts "phrases: #{phrases.inspect}"
        phrases.each {|p| parse_add_text p}
      end
    end

    friend_names.each do |name|
      add_text name, 1
    end


    return phrases
  end

  def friend_names(id='me')
    results_for_facebook_feed(id,'friends').data.collect(&:name)
  end

  def friend_ids(id='me')
    results_for_facebook_feed(id, 'friends').data.collect(&:id)
  end


  def phrases_for_facebook_feed(id,type,text_fields=[:name])
    res = results_for_facebook_feed(id,type)

    phrases = res.data.collect do |entry|

      if entry.respond_to?(:id)
        # puts "Checking id for #{entry}"
        if ids_processed.include?(entry.id)
          puts "Already have: #{entry.id}, skipping..."
          next
        else
          ids_processed << entry.id
        end
      end

      text_fields.collect do |field_name|
        puts "getting #{field_name} for #{entry}"
        entry.send(field_name)
      end
    end
    phrases.flatten.compact
  end

  def results_for_facebook_feed(id, type)
    MiniFB.get(access_token, id, :metadata => true, :type=>type)
  end

  def snapshot

    fields_with_data = {
      'interests' => [:name],
      'activities'=> [:name],
      'music'=> [:name],
      'videos'=> [:name],
      'television'=> [:name],
      'movies'=> [:name],
      'likes'=> [:name],
      'books' => [:name]
      
    }

    fields_simple = [
      'name',
      'bio',
      'quotes',
      'website',         
      'education',
      'work', 
      'hometown' ]


    snapshot = MiniFB.get(access_token, 'me', :fields =>  fields_simple + fields_with_data.keys )

    [:name, :bio, :quotes, :website ].each do |field|
      add_text snapshot.send(field), 2 if snapshot.has_key? field
    end
   
    if snapshot.has_key?('hometown')
      add_text snapshot.hometown.name, 2
    end

    if snapshot.has_key?('education')
      snapshot.education.collect {|entry| entry.school.name}.each do |school|
        add_text school, 2
      end
    end

    if snapshot.has_key?('work')
      snapshot.work.collect {|entry| entry.employer.name}.each do |employer|
        add_text employer, 2
      end
    end

    fields_with_data.each_pair do |type, fields|
      #puts "------------field => #{field}"
      if snapshot.has_key?(type)
        field_results = snapshot.send type
        field_results['data'].each do |entry|
          #puts "------------entry => #{entry}"
          fields.collect do |item|
            #puts "------------item => #{item}"
            add_text(entry.send(item), 3)
          end #item
        end #entry
      end #if key
    end #each_pair
    
    Rails.logger.info "phrases => #{phrases}"
    return phrases
  end

  def picture

  end

  def dig

  end
  
  def friends_videos
      
  end
      
end


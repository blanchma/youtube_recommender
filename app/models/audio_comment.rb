class AudioComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :video
  
  attr_reader :action
 
  has_many :audio_ratings


  def from
    user.nickname
  end

  def duration
    # size.floor
    t = Time.at(size)
    t.strftime("%M:%S")
  end

  def as_json(options={})
    extra_methods = [
      :from,
    :duration,
    :action ]
    json_object = super
    extra_methods.each {|m| json_object[m] = send(m)}

    json_object
  end
  
  def action_from (user_id)
    ratings = audio_ratings.where(:user_id => user_id)    
    @action = ratings.first.action unless ratings.empty?        
  end
  
end


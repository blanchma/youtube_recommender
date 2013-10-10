class AudioRating < ActiveRecord::Base
  belongs_to :user
  belongs_to :audio_comment

  validates :action,   :inclusion => ['liked','hated']



  def hated?
    action == 'hated'
  end

  def liked?
    action == 'liked'
  end

 

end


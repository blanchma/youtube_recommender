class LikeEvent < Event
  belongs_to :video

  #validates :video, :presence => true

  def message
    self.video.from="like"
    self.video.more = {:from_name => self.from_name }   
 
    "#{from_name} liked: <a class='link_video' video='true' id='vid_#{video.id}' href='#hoverbox' >#{video.title}</a>
    <a href='#' class='mini_icons cueExternal' id='cueEvent_#{id}' ><img src='/images/icons/btn_play_green.png' height='12' width='12' title='Play now'></a>
    <a class='mini_icons' href='#' onclick='Mynewtv.enqueueExternal(\"ev_#{id}\")'><img src='/images/icons/btn_playlist_magenta.png' height='12' width='12' title='Add to playlist'></a>"
  end
  
  def as_json(options={})
    extra_methods = [
    :video ]
    json_object = super
    extra_methods.each {|m| json_object[m] = send(m)}

    json_object
  end

end


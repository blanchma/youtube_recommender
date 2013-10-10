module PlayerHelper
  def liked_it_button(options={})
    link_to 'I Liked It!', '#',{"onclick" => "Mynewtv.likeCurrentVideo();return false;"}.merge(options)
  end

  def skip_it_button(options={})
    link_to 'Skip It!', '#',{"onclick" => "Mynewtv.skipCurrentVideo();return false;"}.merge(options)
  end

  def hated_it_button(options={})
    link_to 'I Hated It!', '#',{"onclick" => "Mynewtv.hateCurrentVideo();return false;"}.merge(options)
  end
  
  def share_on_fb_popup_button(text)
    content_tag(:a, :href=>'javascript:Mynewtv.popupPostForm(Mynewtv.currentVideo.id);', :class => 'fb_button fb_button_large') do
      content_tag(:span, :class => 'fb_button_text') do
        text
      end
    end
  end
  
  def form_for_toggle_publishing(&block)
    form_for current_user, :url => toggle_publishing_preferences_path, :method => :put, :remote => true, &block
  end
end

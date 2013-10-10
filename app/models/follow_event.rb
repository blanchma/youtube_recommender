class FollowEvent < Event

  def message
    "#{from_name} is now following you"
  end

end


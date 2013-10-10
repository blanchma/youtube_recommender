class UnfollowEvent < Event

  def message
    "#{from_name} is no longer following you"
  end

end


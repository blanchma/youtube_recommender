class Array
  def average
    return 0 if size == 0
    sum.to_f / size
  end
end

class Array
  def shuffle
    sort_by { rand <=> rand }
  end
end
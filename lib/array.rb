class Array
  def shuffle
    sort_by { |a| rand <=> rand }
  end
end
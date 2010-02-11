module CalcMath
  def self.number_with_limits(number, min, max)
    if number.nil?
      nil
    else
      if number.to_f < min
        min
      elsif number.to_f > max
        max
      else
        number
      end
    end
  end
  
  def self.dot_product_e l1, l2
    sum = 0
    for i in 0...l1.size
        sum += l1[i] * l2[i]
    end
    sum
  end
end
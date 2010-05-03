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
  
  def self.number_to_intensity(number, low = 0, high = 100)
    number = 0 if number < 0
    number = 255 if number > 255
    
    red = number
    green = 255 - number
    
    # red = (((30 - number).abs % 30) * 255)
    # green = 255 - (((30 - number).abs % 30) * 255)
    
    CalcMath::rgb_to_hex(red, green, 0)
  end
  
  def self.rgb_to_hex(r, g, b)
    red = "%02x" % r
    green = "%02x" % g
    blue = "%02x" % b
    "##{red}#{green}#{blue}"
  end
end
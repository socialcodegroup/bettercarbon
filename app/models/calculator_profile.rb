class CalculatorProfile
  def initialize
    # CarbonCalculator.modules.each do |mod|
    #   mod.possible_inputs.each do |input|
    #     instance_variable_set("@#{mod::REFINED_MODEL}_#{input[:name]}".to_sym, nil)
    #   end
    # end
  end
  
  def method_missing(name, *args)
    # super unless name.to_s =~ /^w+_ismyname$/
    # puts "Why, hello #{name}!"
    # instance_variable_get("@#{name}".to_sym)
    nil
  end
end
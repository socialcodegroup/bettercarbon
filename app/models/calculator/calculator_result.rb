class CalculatorResult
  attr_accessor :module_results
  
  def initialize(per_module_results)
    self.module_results = per_module_results
  end
  
  def per_module_results
    # module_results#.keys.map {|key| [key, module_results[key]]}
    CarbonCalculator.modules.collect { |mod|
      [mod, module_results[mod]]
    }
  end
  
  def total_footprint
    module_results.blank? ? 0 : module_results.values.collect{|v|v[:footprint]}.sum
  end
end
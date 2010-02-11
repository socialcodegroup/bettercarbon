class CarbonCalculator
  def self.process(calculator_input)
    return CalculatorResult.new unless calculator_input
    modules_map = {}
    CarbonCalculator.modules.each{ |m| modules_map[m] = m.new(calculator_input).process }
    CalculatorResult.new(modules_map)
  end
  
  def self.modules
    [
      Modules::Transportation,
      Modules::AirTravel,
      Modules::HomeEnergy,
      Modules::Food,
      Modules::GoodsAndServices
      # Modules::FoodsGoodsAndServices
    ]
  end
end
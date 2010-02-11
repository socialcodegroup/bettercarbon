class RefinedHousingValue < ActiveRecord::Base
  belongs_to :query
  
  before_save :enfore_min_max_limits
  
  validates_uniqueness_of :query_id
  
  private
  
    def enfore_min_max_limits
      self.electricity_costs        = CalcMath::number_with_limits(self.electricity_costs, 0, 500)
      self.natural_gas_costs        = CalcMath::number_with_limits(self.natural_gas_costs, 0, 200)
      self.other_fuel_costs         = CalcMath::number_with_limits(self.other_fuel_costs, 0, 200)
      self.water_and_sewage_costs   = CalcMath::number_with_limits(self.water_and_sewage_costs, 0, 200)
      self.square_feet_of_household = CalcMath::number_with_limits(self.square_feet_of_household, 0, 10000)
    end
end

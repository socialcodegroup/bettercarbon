class RefinedFoodValue < ActiveRecord::Base
  belongs_to :query
  
  before_save :enfore_min_max_limits
  
  validates_uniqueness_of :query_id
  
  private
  
    def enfore_min_max_limits
      self.meat_fish_protein        = CalcMath::number_with_limits(self.meat_fish_protein, 0, 500)
      self.cereals_bakery_products  = CalcMath::number_with_limits(self.cereals_bakery_products, 0, 500)
      self.dairy                    = CalcMath::number_with_limits(self.dairy, 0, 500)
      self.fruits_and_veg           = CalcMath::number_with_limits(self.fruits_and_veg, 0, 500)
      self.eating_out               = CalcMath::number_with_limits(self.eating_out, 0, 500)
      self.other                    = CalcMath::number_with_limits(self.other, 0, 500)
      self.other_foods              = CalcMath::number_with_limits(self.other_foods, 0, 500)
    end
end

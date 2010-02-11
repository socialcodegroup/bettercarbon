class RefinedGoodsAndServicesValue < ActiveRecord::Base
  belongs_to :query
  
  before_save :enfore_min_max_limits
  
  validates_uniqueness_of :query_id
  
  private
  
    def enfore_min_max_limits
      self.other                    = CalcMath::number_with_limits(self.other, 0, 500)
      self.clothing                 = CalcMath::number_with_limits(self.clothing, 0, 500)
      self.furnishings              = CalcMath::number_with_limits(self.furnishings, 0, 500)
      self.other_goods              = CalcMath::number_with_limits(self.other_goods, 0, 1000)
      self.services                 = CalcMath::number_with_limits(self.services, 0, 2000)
    end
end

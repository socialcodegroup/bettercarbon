class RefinedTransportationValue < ActiveRecord::Base
  belongs_to :query
  
  before_save :enfore_min_max_limits
  
  validates_uniqueness_of :query_id
  
  private
  
    def enfore_min_max_limits
      self.miles_driven = CalcMath::number_with_limits(self.miles_driven, 0, 100000)
      self.mpg          = CalcMath::number_with_limits(self.mpg, 0, 100)
    end
end

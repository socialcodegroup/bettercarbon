class RefinedAirTravelValue < ActiveRecord::Base
  belongs_to :query
  
  before_save :enfore_min_max_limits
  
  validates_uniqueness_of :query_id
  
  private
  
    def enfore_min_max_limits
      self.num_short_trips    = CalcMath::number_with_limits(self.num_short_trips, 0, 100)
      self.num_medium_trips   = CalcMath::number_with_limits(self.num_medium_trips, 0, 100)
      self.num_long_trips     = CalcMath::number_with_limits(self.num_long_trips, 0, 100)
      self.num_extended_trips = CalcMath::number_with_limits(self.num_extended_trips, 0, 100)
    end
end

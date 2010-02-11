class ClaimedAddress < ActiveRecord::Base
  attr_accessor :suggestion
  
  validates_uniqueness_of :query_id
  
  belongs_to :query
  belongs_to :user
  
  after_create :save_suggestion
  
  def save_suggestion
    query.update_attribute(:suggestion, suggestion) unless suggestion.blank?
  end
end

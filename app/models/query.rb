class Query < ActiveRecord::Base
  has_one :refined_air_travel_value, :dependent => :destroy
  has_one :refined_food_value, :dependent => :destroy
  has_one :refined_goods_and_services_value, :dependent => :destroy
  has_one :refined_foods_goods_and_services_value, :dependent => :destroy
  has_one :refined_housing_value, :dependent => :destroy
  has_one :refined_transportation_value, :dependent => :destroy
  
  after_create :create_query_tags_ids
  
  has_one :claimed_address, :dependent => :destroy
  
  validates_presence_of :lat, :unless => Proc.new { |q| !q.facebook_uid.blank? }
  validates_presence_of :lng, :unless => Proc.new { |q| !q.facebook_uid.blank? }
  validates_presence_of :street_address, :unless => Proc.new { |q| !q.facebook_uid.blank? }
  validates_presence_of :city, :unless => Proc.new { |q| !q.facebook_uid.blank? }
  validates_presence_of :state, :unless => Proc.new { |q| !q.facebook_uid.blank? }
  validates_presence_of :zip, :unless => Proc.new { |q| !q.facebook_uid.blank? }
  validates_presence_of :country, :unless => Proc.new { |q| !q.facebook_uid.blank? }
  
  validates_uniqueness_of :street_address, :scope => [:city, :state, :zip, :country], :unless => Proc.new { |q| !q.facebook_uid.blank? }
  
  has_many :query_tags, :dependent => :destroy
  
  acts_as_mappable
  
  attr_accessor :query_tags_ids, :percision
  
  NEIGHBORHOOD_SIZE = 50
  
  def full_address
    [street_address, city, "#{state} #{zip}", country].collect(&:strip).join(', ')
    # "#{street_address}, #{city}, #{state} #{zip}, #{country}"
  end
  
  def self.locate_from_fb_id(fb_id)
    find(:first, :conditions => ['facebook_uid = ?', fb_id])
  end
  
  def self.locate_from_input(street_address, city, state, zip, country_code)
    find(:first, :conditions => ['street_address = ? and city = ? and state = ? and zip = ? and country = ?', street_address, city, state, zip, country_code])
  end
  
  def clear_similarity_cache
    Rails.cache.delete("similar_inputs/#{lat},#{lng}/#{NEIGHBORHOOD_SIZE}")
  end
  
  def similar_inputs(params)
    if !facebook_uid.blank? && params[:facebook]
      similar_inputs_via_facebook
    else
      similar_inputs_via_location
    end
  end
  
  def similar_inputs_via_facebook
    Rails.cache.fetch("similar_inputs/#{facebook_uid}", :expires_in => 300) {
      fb_user = Facebooker::User.new(facebook_uid)
      
      fb_ids_with_app = fb_user.friend_ids_with_this_app
      fb_ids_with_app = fb_ids_with_app[0..NEIGHBORHOOD_SIZE] if fb_ids_with_app.length > NEIGHBORHOOD_SIZE
      
      if fb_ids_with_app.count > 0
        similar_inputs = Query.find(:all, :conditions => ['facebook_uid in (?)', fb_ids_with_app.join(', ')], :limit => NEIGHBORHOOD_SIZE)
      else
        similar_inputs = []
      end

      filtered_similar_inputs = []

      similar_inputs.each do |input|
        next if input.id == self.id

        person_1_ordered_shared_fields = []
        person_2_ordered_shared_fields = []

        CarbonCalculator.modules.collect do |mod|
          mod.input_variables_statistics.collect do |variable|
            d_var1 = mod.actual_value_for_variable(self, variable[:name], :only_exact => true)
            d_var2 = mod.actual_value_for_variable(input, variable[:name], :only_exact => true)

            if d_var1 && d_var2 && variable[:maximum] && variable[:minimum]
              max_minus_min = variable[:maximum] - variable[:minimum]
              max_minus_min = 1 if max_minus_min == 0
              person_1_ordered_shared_fields << ((d_var1[:value] - variable[:minimum]) / max_minus_min)
              person_2_ordered_shared_fields << ((d_var2[:value] - variable[:minimum]) / max_minus_min)
            end
          end
        end

        a_dot_b = CalcMath::dot_product_e(person_1_ordered_shared_fields, person_2_ordered_shared_fields)
        a_dot_a = CalcMath::dot_product_e(person_1_ordered_shared_fields, person_1_ordered_shared_fields)
        b_dot_b = CalcMath::dot_product_e(person_2_ordered_shared_fields, person_2_ordered_shared_fields)

        begin
          cosine_similarity = a_dot_b / (Math.sqrt(a_dot_a) * Math.sqrt(b_dot_b))
        rescue
          cosine_similarity = 0
        end

        filtered_similar_inputs << {:input => input.id, :cosine_similarity => cosine_similarity} if cosine_similarity > 0.1
      end

      # if filtered_similar_inputs.blank? && !fb_ids_with_app.blank?
      #   filtered_similar_inputs = Query.find(:all, :conditions => ['facebook_uid in (?)', fb_ids_with_app.join(', ')], :limit => NEIGHBORHOOD_SIZE).collect{|q| {:input => q, :cosine_similarity => 0}}
      #   max_dist = filtered_similar_inputs.last[:input].distance.to_f
      #   filtered_similar_inputs = filtered_similar_inputs.collect{|similar_input| {:input => similar_input[:input].id, :cosine_similarity => (max_dist - similar_input[:input].distance.to_f) / max_dist} }
      # end
      
      filtered_similar_inputs
    }
  end
  
  def similar_inputs_via_location
    Rails.cache.fetch("similar_inputs/#{lat},#{lng}/#{NEIGHBORHOOD_SIZE}", :expires_in => 300) {
      similar_inputs = Query.find(:all, :origin=> [lat, lng], :order=>'distance asc', :limit => NEIGHBORHOOD_SIZE)

      filtered_similar_inputs = []

      similar_inputs.each do |input|
        next if input.id == self.id

        person_1_ordered_shared_fields = []
        person_2_ordered_shared_fields = []

        CarbonCalculator.modules.collect do |mod|
          mod.input_variables_statistics.collect do |variable|
            d_var1 = mod.actual_value_for_variable(self, variable[:name], :only_exact => true)
            d_var2 = mod.actual_value_for_variable(input, variable[:name], :only_exact => true)

            if d_var1 && d_var2 && variable[:maximum] && variable[:minimum]
              max_minus_min = variable[:maximum] - variable[:minimum]
              max_minus_min = 1 if max_minus_min == 0
              person_1_ordered_shared_fields << ((d_var1[:value] - variable[:minimum]) / max_minus_min)
              person_2_ordered_shared_fields << ((d_var2[:value] - variable[:minimum]) / max_minus_min)
            end
          end
        end

        a_dot_b = CalcMath::dot_product_e(person_1_ordered_shared_fields, person_2_ordered_shared_fields)
        a_dot_a = CalcMath::dot_product_e(person_1_ordered_shared_fields, person_1_ordered_shared_fields)
        b_dot_b = CalcMath::dot_product_e(person_2_ordered_shared_fields, person_2_ordered_shared_fields)

        begin
          cosine_similarity = a_dot_b / (Math.sqrt(a_dot_a) * Math.sqrt(b_dot_b))
        rescue
          cosine_similarity = 0
        end

        filtered_similar_inputs << {:input => input.id, :cosine_similarity => cosine_similarity} if cosine_similarity > 0.1
      end

      if filtered_similar_inputs.blank?
        filtered_similar_inputs = Query.find(:all, :origin=> [lat, lng], :order=>'distance asc', :limit => NEIGHBORHOOD_SIZE).collect{|q| {:input => q, :cosine_similarity => 0}}
        max_dist = filtered_similar_inputs.last[:input].distance.to_f
        filtered_similar_inputs = filtered_similar_inputs.collect{|similar_input| {:input => similar_input[:input].id, :cosine_similarity => (max_dist - similar_input[:input].distance.to_f) / max_dist} }
      end
      filtered_similar_inputs
    }
  end
  
  private
  
    def create_query_tags_ids
      return if query_tags_ids.blank?
      query_tags_ids.each do |tag_id|
        QueryTag.create(:query_id => self.id, :tag_id => tag_id)
      end
    end
end

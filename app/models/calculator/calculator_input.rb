class CalculatorInput
  include Geokit::Geocoders
  
  attr_accessor :address, :tags, :tags_array, :user_input
  
  def destroy_cache
    user_input.reload
    user_input.clear_similarity_cache
  end
  
  # Author:: Nitin Shantharam (mailto:nitin@)
  def initialize(params = {})
    params.each{|k,v|send("#{k}=", v)} if params
    
    loc = MultiGeocoder.geocode(address)
    if loc.success && (loc.precision == "address" || loc.precision == "zip+4") && loc.country_code == "US"
      self.user_input = Query.locate_from_input(loc.street_address, loc.city, loc.state, loc.zip, loc.country_code)
      
      self.tags_array = tags.split(',').collect{ |t|
        tag = Tag.find_by_phrase(t.strip)
        if tag.blank? && !t.blank?
          Tag.create(:phrase => t)
        elsif !t.blank?
          tag
        else
          nil
        end
      }.compact
      
      unless self.user_input
        self.user_input = Query.create(
          :input => address,
          :street_address => loc.street_address,
          :lat => loc.lat,
          :lng => loc.lng,
          :city => loc.city,
          :state => loc.state,
          :zip => loc.zip,
          :country => loc.country_code,
          :query_tags_ids => tags_array.collect(&:id)
        )
      else
        # update the tags
        QueryTag.delete_all("query_id = #{self.user_input.id}")
        self.user_input.update_attribute(:tags_cache, nil)
        
        tags_array.each do |tag|
          QueryTag.create(:query_id => self.user_input.id, :tag_id => tag.id)
        end
      end
      
      self.user_input.percision = loc.precision
    elsif loc.success && (loc.precision == "zip" || loc.precision == "state") && loc.country_code == "US"
      self.user_input = Query.new(
        :input => address,
        :street_address => loc.street_address,
        :lat => loc.lat,
        :lng => loc.lng,
        :city => loc.city,
        :state => loc.state,
        :zip => loc.zip,
        :country => loc.country_code,
        :percision => loc.precision
      )
    else
      raise InvalidInputException.new
    end
  end
end
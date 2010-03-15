class Modules::Transportation
  REFINED_MODEL = :refined_transportation_value
  
  def self.pretty_module_name
    "Car & Public Travel"
  end
  
  # do not modify
  def initialize(calculator_input)
    @calculator_input = calculator_input
  end
  
  def process
    miles_driven            = self.class.actual_value_for_variable(@calculator_input.user_input, :miles_driven, :facebook => @calculator_input.facebook)
    mpg                     = self.class.actual_value_for_variable(@calculator_input.user_input, :mpg, :facebook => @calculator_input.facebook)
    miles_public_transport  = self.class.actual_value_for_variable(@calculator_input.user_input, :miles_public_transport, :facebook => @calculator_input.facebook)
    fuel_type               = self.class.actual_value_for_variable(@calculator_input.user_input, :fuel_type, :facebook => @calculator_input.facebook)
    vehicle_size            = self.class.actual_value_for_variable(@calculator_input.user_input, :vehicle_size, :facebook => @calculator_input.facebook)
    
    footprint = self.class.result_for_values(
      miles_driven[:value],
      mpg[:value],
      fuel_type[:value],
      miles_public_transport[:value],
      vehicle_size[:value]
    )
    
    {
      :footprint              => footprint,
      :miles_driven           => miles_driven,
      :mpg                    => mpg,
      :miles_public_transport => miles_public_transport,
      :vehicle_size           => vehicle_size,
      :fuel_type              => fuel_type
    }
  end
  
  ###############
  # static ######
  ###############
  
  def self.average_result
    {
      :footprint              => 0,
      :miles_driven           => {:value => 11900, :calculation => :average},
      :mpg                    => {:value => 22.5, :calculation => :average},
      :miles_public_transport => {:value => 0, :calculation => :average},
      :fuel_type              => {:value => 0, :calculation => :average},
      :vehicle_size           => {:value => 1, :calculation => :average},
    }
  end
  
  # do not modify
  def self.actual_value_for_variable(input, variable, options = {})
    if (input.send(REFINED_MODEL).blank? || input.send(REFINED_MODEL)[variable.to_sym].blank?) && !options[:only_exact]
      if input.similar_inputs(:facebook => options[:facebook]).blank?
        self.average_result[variable.to_sym]
      else
        calculate_average_on_users_for_variable(input.similar_inputs(:facebook => options[:facebook]), variable)
      end
    elsif input.send(REFINED_MODEL)
      value = input.send(REFINED_MODEL)[variable.to_sym]
      if value
        {:value => input.send(REFINED_MODEL)[variable.to_sym], :calculation => :exact}
      else
        nil
      end
    else
      nil
    end
  end
  
  # do not modify
  def self.calculate_average_on_users_for_variable(similar_inputs, variable)
    loaded_inputs_with_data = Query.find(similar_inputs.collect{|si|si[:input]})
    
    loaded_inputs_with_data = similar_inputs.select {|si|
      i = Query.find(si[:input])
      !i.send(REFINED_MODEL).blank? && !i.send(REFINED_MODEL)[variable.to_sym].blank?
    }
    
    if loaded_inputs_with_data.size > 0
      var_average = loaded_inputs_with_data.sum{|si|Query.find(si[:input]).send(REFINED_MODEL)[variable.to_sym]*si[:cosine_similarity]} / loaded_inputs_with_data.sum{|si|si[:cosine_similarity]}
      if var_average.nan?
        self.average_result[variable.to_sym]
      else
        {:value => var_average, :calculation => :average}
      end
    else
      self.average_result[variable.to_sym]
    end
  end
  
  def self.result_for_values(miles_driven, mpg, fuel_type, miles_public_transport, vehicle_size)
    fuel_used = mpg!=0 ? miles_driven / mpg : 0 #if mpg=0, has no car
    
    if (fuel_type.to_f + 0.5).to_i == 0
      fuel_emissions = fuel_used * (9109 + 2389)
    else
      fuel_emissions = fuel_used * (10508 + 2515)
    end
    
    if (vehicle_size.to_f + 0.5).to_i == 0 #small
      size_mod = 1.59 #3180 lbs
    elsif (vehicle_size.to_f + 0.5).to_i == 1 #mid-sized
      size_mod = 1.7885 #3557 lbs
    elsif (vehicle_size.to_f + 0.5).to_i == 2 #Van/SUV
      size_mod = 2.2835 #4567 lbs
    elsif (vehicle_size.to_f + 0.5).to_i == 3 #truck
      size_mod = 2.371 #4742 lbs
    elsif (vehicle_size.to_f + 0.5).to_i == 4 #pickup
      size_mod = 2.6095 #5219 lbs
    else
      size_mod = 1.7885 #default to mid-sized car/wagon
    end
    
    
    manufacturing_emissions = mpg!=0 ? miles_driven * (7890776 * size_mod / 160000) : 0
    
    driving_emissions = mpg!=0 ? fuel_emissions + manufacturing_emissions : 0
    
    public_transport_emissions = miles_public_transport * 12 * 179 * 1.2
    
    (driving_emissions + manufacturing_emissions + public_transport_emissions) * 0.000001 * 1.10231131 # to metric tons to short tons
  end
  
  def self.possible_inputs
    [
      {:type => :text_field,  :name => 'miles_driven',            :title => 'Number of miles driven per year'},
      {:type => :text_field,  :name => 'mpg',                     :title => 'Miles per gallon'},
      {:type => :select,      :name => 'fuel_type',               :title => 'Vehicle fuel type', :options => {'Gasoline' => "0", 'Diesel' => "1"}},
      {:type => :select,      :name => 'vehicle_size',            :title => 'Vehicle size', :options => {'Small car' => "0", 'Mid-sized car' => "1", 'Van/SUV' => "2", 'Truck' => "3", 'Pickup' => "4"}},
      {:type => :text_field,  :name => 'miles_public_transport',  :title => 'Miles traveled via public transportation per month'}
    ]
  end
  
  def self.input_variables_statistics
    possible_inputs.collect { |input_variable|
      max = Rails.cache.fetch("#{self.name}/var/#{input_variable[:name]}/max", :expires_in => 1800) { RefinedTransportationValue.maximum(input_variable[:name]) }
      min = Rails.cache.fetch("#{self.name}/var/#{input_variable[:name]}/min", :expires_in => 1800) { RefinedTransportationValue.minimum(input_variable[:name]) }
      
      input_variable.merge(
        :maximum => max,
        :minimum => min
      )
    }
  end
  
  def self.average_value_for_input_variable_for_city_state_country(variable, city, state, country)
    Rails.cache.fetch("#{self.name}/var/#{variable}/average", :expires_in => 1800) {
      RefinedTransportationValue.average(variable, :include => :query, :conditions => ['queries.city = ? and queries.state = ? and queries.country = ? and ? is not null', city, state, country, variable])
    }
  end
  
  def self.process_input(calculator_input, refined_params)
    if calculator_input.user_input.send(REFINED_MODEL)
      calculator_input.user_input.send(REFINED_MODEL).destroy
    end
    
    RefinedTransportationValue.create(
      :query_id               => calculator_input.user_input.id,
      :miles_driven           => refined_params[:miles_driven],
      :mpg                    => refined_params[:mpg],
      :fuel_type              => refined_params[:fuel_type],
      :vehicle_size           => refined_params[:vehicle_size],
      :miles_public_transport => refined_params[:miles_public_transport]
    )
  end
end

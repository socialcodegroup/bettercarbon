class Modules::AirTravel
  REFINED_MODEL = :refined_air_travel_value
  
  def self.pretty_module_name
    "Air Travel"
  end
  
  # do not modify
  def initialize(calculator_input)
    @calculator_input = calculator_input
  end
  
  def process
    num_short_trips    = self.class.actual_value_for_variable(@calculator_input.user_input, :num_short_trips)
    num_medium_trips   = self.class.actual_value_for_variable(@calculator_input.user_input, :num_medium_trips)
    num_long_trips     = self.class.actual_value_for_variable(@calculator_input.user_input, :num_long_trips)
    num_extended_trips = self.class.actual_value_for_variable(@calculator_input.user_input, :num_extended_trips)
    
    footprint = self.class.result_for_values(
      num_short_trips[:value],
      num_medium_trips[:value],
      num_long_trips[:value],
      num_extended_trips[:value]
    )
    
    {
      :footprint          => footprint,
      :num_extended_trips => num_extended_trips,
      :num_long_trips     => num_long_trips,
      :num_medium_trips   => num_medium_trips,
      :num_short_trips    => num_short_trips
    }
  end
  
  ###############
  # static ######
  ###############
  
  def self.average_result
    {
      :footprint          => 0,
      :num_extended_trips => {:value => 1, :calculation => :average},
      :num_long_trips     => {:value => 0, :calculation => :average},
      :num_medium_trips   => {:value => 0, :calculation => :average},
      :num_short_trips    => {:value => 0, :calculation => :average}
    }
  end
  
  # do not modify
  def self.actual_value_for_variable(input, variable, options = {})
    if (input.send(REFINED_MODEL).blank? || input.send(REFINED_MODEL)[variable.to_sym].blank?) && !options[:only_exact]
      if input.similar_inputs(:facebook => @calculator_input.facebook).blank?
        self.average_result[variable.to_sym]
      else
        calculate_average_on_users_for_variable(input.similar_inputs(:facebook => @calculator_input.facebook), variable)
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
  
  def self.result_for_values(num_short_trips, num_medium_trips, num_long_trips, num_extended_trips)
    v = ((num_short_trips * 254 * 300) + (num_medium_trips * 204 * 950) + (num_long_trips * 181 * 2250) + (num_extended_trips * 172 * 5000)) * 1.2 * 1.9
    v * 0.000001 * 1.10231131 # to metric tons to short tons
  end
  
  def self.possible_inputs
    [
      {:type => :text_field,  :name => 'num_short_trips',    :title => 'Number of short trips (<400mi) per year. (Round trips are 2 flights)',},
      {:type => :text_field,  :name => 'num_medium_trips',   :title => 'Number of medium trips (400-1500mi) per year. (Round trips are 2 flights)'},
      {:type => :text_field,  :name => 'num_long_trips',     :title => 'Number of long trips (1500-3000mi) per year. (Round trips are 2 flights)'},
      {:type => :text_field,  :name => 'num_extended_trips', :title => 'Number of extended trips (>3000mi) per year. (Round trips are 2 flights)'}
      
      # Just examples
      # {:type => :check_box,   :name => 'num_extended_trips', :title => 'I have a car that runs on gas.'},
      # {:type => :select,      :name => 'num_extended_trips', :title => 'I drive a:', :options => {'Car' => "0", 'SUV' => "1", 'Truck' => "2"}}
    ]
  end
  
  def self.input_variables_statistics
    possible_inputs.collect { |input_variable|
      max = Rails.cache.fetch("#{self.name}/var/#{input_variable[:name]}/max", :expires_in => 1800) { RefinedAirTravelValue.maximum(input_variable[:name]) }
      min = Rails.cache.fetch("#{self.name}/var/#{input_variable[:name]}/min", :expires_in => 1800) { RefinedAirTravelValue.minimum(input_variable[:name]) }
      
      input_variable.merge(
        :maximum => max,
        :minimum => min
      )
    }
  end
  
  def self.average_value_for_input_variable_for_city_state_country(variable, city, state, country)
    Rails.cache.fetch("#{self.name}/var/#{variable}/average", :expires_in => 1800) {
      RefinedAirTravelValue.average(variable, :include => :query, :conditions => ['queries.city = ? and queries.state = ? and queries.country = ? and ? is not null', city, state, country, variable])
    }
  end
  
  def self.process_input(calculator_input, refined_params)
    if calculator_input.user_input.send(REFINED_MODEL)
      calculator_input.user_input.send(REFINED_MODEL).destroy
    end
    
    RefinedAirTravelValue.create(
      :query_id           => calculator_input.user_input.id,
      :num_short_trips    => refined_params[:num_short_trips],
      :num_medium_trips   => refined_params[:num_medium_trips],
      :num_long_trips     => refined_params[:num_long_trips],
      :num_extended_trips => refined_params[:num_extended_trips]
    )
  end
end
class Modules::HomeEnergy
  REFINED_MODEL = :refined_housing_value
  ELECTRICITY_PRICE = 0.0987 #us average
  ELECTRICITY_EMISSIONS_RATE = 606.1394 #us average
  NATURAL_GAS_PRICE = 1.368 #us average
  NATURAL_GAS_EMISSIONS_RATE = 5311
  OTHER_FUEL_EMISSIONS_RATE = 879
  WATER_AND_SEWAGE_EMISSIONS_RATE = 4042
  HOUSING_EMISSIONS = 965
  
  def self.pretty_module_name
    "Home Energy"
  end
  
  # do not modify
  def initialize(calculator_input)
    @calculator_input = calculator_input
  end
  
  def process
    electricity_costs         = self.class.actual_value_for_variable(@calculator_input.user_input, :electricity_costs, :facebook => @calculator_input.facebook)
    natural_gas_costs         = self.class.actual_value_for_variable(@calculator_input.user_input, :natural_gas_costs, :facebook => @calculator_input.facebook)
    other_fuel_costs          = self.class.actual_value_for_variable(@calculator_input.user_input, :other_fuel_costs, :facebook => @calculator_input.facebook)
    water_and_sewage_costs    = self.class.actual_value_for_variable(@calculator_input.user_input, :water_and_sewage_costs, :facebook => @calculator_input.facebook)
    square_feet_of_household  = self.class.actual_value_for_variable(@calculator_input.user_input, :square_feet_of_household, :facebook => @calculator_input.facebook)
    
    
    if @calculator_input.user_input.state.blank?
      state = nil
    else
      state = @calculator_input.user_input.state
    end
    
    housing_stat = HousingStat.find_by_state(state)
    
    if housing_stat
      e_price = housing_stat.electricity_price
      e_emissions_rate = housing_stat.electricity_emissions
      natural_gas_price = housing_stat.natural_gas_price
    else
      e_price = ELECTRICITY_PRICE
      e_emissions_rate = ELECTRICITY_EMISSIONS_RATE
      natural_gas_price = NATURAL_GAS_PRICE
    end
    
    footprint = self.class.result_for_values(
      electricity_costs[:value],
      e_price,
      e_emissions_rate,
      natural_gas_costs[:value],
      natural_gas_price,
      NATURAL_GAS_EMISSIONS_RATE,
      other_fuel_costs[:value],
      OTHER_FUEL_EMISSIONS_RATE,
      water_and_sewage_costs[:value],
      WATER_AND_SEWAGE_EMISSIONS_RATE,
      square_feet_of_household[:value],
      HOUSING_EMISSIONS
    )
    
    {
      :footprint                => footprint,
      :electricity_costs        => electricity_costs,
      :natural_gas_costs        => natural_gas_costs,
      :other_fuel_costs         => other_fuel_costs,
      :water_and_sewage_costs   => water_and_sewage_costs,
      :square_feet_of_household => square_feet_of_household
    }
  end
  
  ###############
  # static ######
  ###############
  
  def self.average_result
    {
      :footprint                => 0,
      :electricity_costs        => {:value => 122, :calculation => :average},
      :natural_gas_costs        => {:value => 40, :calculation => :average},
      :other_fuel_costs         => {:value => 10, :calculation => :average},
      :water_and_sewage_costs   => {:value => 30, :calculation => :average},
      :square_feet_of_household => {:value => 1900, :calculation => :average}
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
  
  def self.result_for_values(electricity_costs, electricity_price, electricity_emissions_rate, natural_gas_costs, natural_gas_price, natural_gas_emissions_rate, other_fuel_costs, other_fuel_emissions_rate, water_and_sewage_costs, water_and_sewage_emissions_rate, square_feet_of_household, housing_emissions)
    electricity_emissions = electricity_costs * 12 / electricity_price * electricity_emissions_rate
    natural_gas_emissions = natural_gas_costs * 12 / natural_gas_price * natural_gas_emissions_rate
    other_fuel_emissions = other_fuel_costs * 12 * other_fuel_emissions_rate
    water_and_sewage_emissions = water_and_sewage_costs * 12 * water_and_sewage_emissions_rate
    housing_construction_emissions = square_feet_of_household * housing_emissions
    
    household_emissions = electricity_emissions + natural_gas_emissions + other_fuel_emissions + water_and_sewage_emissions + housing_construction_emissions
    
    household_emissions * 0.000001 * 1.10231131 # to metric tons to short tons
    
  end
  
  def self.possible_inputs
    [
      {:type => :text_field, :name => 'electricity_costs',        :title => '$ spent on electricity per month'},
      {:type => :text_field, :name => 'natural_gas_costs',        :title => '$ spent on natural gas per month'},
      {:type => :text_field, :name => 'other_fuel_costs',         :title => '$ spent on other fuel per month'},
      {:type => :text_field, :name => 'water_and_sewage_costs',   :title => '$ spent on water and sewage per month'},
      {:type => :text_field, :name => 'square_feet_of_household', :title => 'Square feet of household'}
    ]
  end
  
  def self.average_value_for_input_variable_for_city_state_country(variable, city, state, country)
    Rails.cache.fetch("#{self.name}/var/#{variable}/average", :expires_in => 1800) {
      RefinedHousingValue.average(variable, :include => :query, :conditions => ['queries.city = ? and queries.state = ? and queries.country = ? and ? is not null', city, state, country, variable])
    }
  end
  
  def self.input_variables_statistics
    possible_inputs.collect { |input_variable|
      max = Rails.cache.fetch("#{self.name}/var/#{input_variable[:name]}/max", :expires_in => 1800) { RefinedHousingValue.maximum(input_variable[:name]) }
      min = Rails.cache.fetch("#{self.name}/var/#{input_variable[:name]}/min", :expires_in => 1800) { RefinedHousingValue.minimum(input_variable[:name]) }
      
      input_variable.merge(
        :maximum => max,
        :minimum => min
      )
    }
  end
  
  def self.process_input(calculator_input, refined_params)
    if calculator_input.user_input.send(REFINED_MODEL)
      calculator_input.user_input.send(REFINED_MODEL).destroy
    end
    
    RefinedHousingValue.create(
      :query_id                 => calculator_input.user_input.id,
      :electricity_costs        => refined_params[:electricity_costs],
      :natural_gas_costs        => refined_params[:natural_gas_costs],
      :other_fuel_costs         => refined_params[:other_fuel_costs],
      :water_and_sewage_costs   => refined_params[:water_and_sewage_costs],
      :square_feet_of_household => refined_params[:square_feet_of_household]
    )
  end
end
class Modules::Food
  REFINED_MODEL = :refined_food_value
  
  def self.pretty_module_name
    "Food"
  end
  
  # do not modify
  def initialize(calculator_input)
    @calculator_input = calculator_input
  end
  
  def process
    meat_fish_protein       = self.class.actual_value_for_variable(@calculator_input.user_input, :meat_fish_protein)
    cereals_bakery_products = self.class.actual_value_for_variable(@calculator_input.user_input, :cereals_bakery_products)
    dairy                   = self.class.actual_value_for_variable(@calculator_input.user_input, :dairy)
    fruits_and_veg          = self.class.actual_value_for_variable(@calculator_input.user_input, :fruits_and_veg)
    eating_out              = self.class.actual_value_for_variable(@calculator_input.user_input, :eating_out)
    other_foods             = self.class.actual_value_for_variable(@calculator_input.user_input, :other_foods)
    eat_organic_food        = self.class.actual_value_for_variable(@calculator_input.user_input, :eat_organic_food)
    
    footprint = self.class.result_for_values(
      meat_fish_protein[:value],
      cereals_bakery_products[:value],
      dairy[:value],
      fruits_and_veg[:value],
      eating_out[:value],
      other_foods[:value],
      eat_organic_food[:value]
    )
    
    {
      :footprint                => footprint,
      :meat_fish_protein        => meat_fish_protein,
      :cereals_bakery_products  => cereals_bakery_products,
      :dairy                    => dairy,
      :fruits_and_veg           => fruits_and_veg,
      :eating_out               => eating_out,
      :other_foods              => other_foods,
      :eat_organic_food         => eat_organic_food
    }
  end
  
  ###############
  # static ######
  ###############
  
  def self.average_result
    {
      :footprint                => 0,
      :meat_fish_protein        => {:value => 66, :calculation => :average},
      :cereals_bakery_products  => {:value => 38, :calculation => :average},
      :dairy                    => {:value => 31, :calculation => :average},
      :fruits_and_veg           => {:value => 50, :calculation => :average},
      :eating_out               => {:value => 224, :calculation => :average},
      :other_foods              => {:value => 102, :calculation => :average},
      :eat_organic_food         => {:value => 0, :calculation => :average}
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
  
  def self.result_for_values(meat_fish_protein, cereals_bakery_products, dairy, fruits_and_veg, eating_out, other_foods, eat_organic_food)
    v = ( (meat_fish_protein * 1452) + (cereals_bakery_products * 741) + (dairy * 1911) + (fruits_and_veg * 1176) + (eating_out * 368) + (other_foods * 467) * 12)
    
    eat_organic_food = 0 if eat_organic_food.nil?
    
    if (eat_organic_food.to_f + 0.5).to_i == 2
      v = v * 0.71
    elsif (eat_organic_food.to_f + 0.5).to_i == 1
      v = v * 0.85
    elsif (eat_organic_food.to_f + 0.5).to_i == 0
      # no change
    end
    
    v * 0.000001 * 1.10231131 # to metric tons to short tons
  end
  
  def self.possible_inputs
    [
      {:type => :text_field,  :name => 'meat_fish_protein',         :title => '$ spent on meat, fish, and protein per month'},
      {:type => :text_field,  :name => 'cereals_bakery_products',   :title => '$ spent on cereals and bakery products per month'},
      {:type => :text_field,  :name => 'dairy',                     :title => '$ spent on dairy per month'},
      {:type => :text_field,  :name => 'fruits_and_veg',            :title => '$ spent on fruits and vegetables per month'},
      {:type => :text_field,  :name => 'eating_out',                :title => '$ spent on eating out per month'},
      {:type => :text_field,  :name => 'other_foods',               :title => '$ spent on other foods per month'},
      {:type => :select,      :name => 'eat_organic_food',          :title => 'Eat organic food', :options => { 'Never or rarely' => '0', 'Sometimes' => "1", 'Most of the time' => "2"}}
    ]
  end
  
  def self.input_variables_statistics
    possible_inputs.collect { |input_variable|
      max = Rails.cache.fetch("#{self.name}/var/#{input_variable[:name]}/max", :expires_in => 1800) { RefinedFoodValue.maximum(input_variable[:name]) }
      min = Rails.cache.fetch("#{self.name}/var/#{input_variable[:name]}/min", :expires_in => 1800) { RefinedFoodValue.minimum(input_variable[:name]) }

      input_variable.merge(
        :maximum => max,
        :minimum => min
      )
    }
  end
  
  def self.average_value_for_input_variable_for_city_state_country(variable, city, state, country)
    Rails.cache.fetch("#{self.name}/var/#{variable}/average", :expires_in => 1800) {
      RefinedFoodValue.average(variable, :include => :query, :conditions => ['queries.city = ? and queries.state = ? and queries.country = ? and ? is not null', city, state, country, variable])
    }
  end
  
  def self.process_input(calculator_input, refined_params)
    if calculator_input.user_input.send(REFINED_MODEL)
      calculator_input.user_input.send(REFINED_MODEL).destroy
    end
    
    RefinedFoodValue.create(
      :query_id                => calculator_input.user_input.id,
      :meat_fish_protein       => refined_params[:meat_fish_protein],
      :cereals_bakery_products => refined_params[:cereals_bakery_products],
      :dairy                   => refined_params[:dairy],
      :fruits_and_veg          => refined_params[:fruits_and_veg],
      :eating_out              => refined_params[:eating_out],
      :other_foods             => refined_params[:other_foods],
      :eat_organic_food        => refined_params[:eat_organic_food]
    )
  end
end
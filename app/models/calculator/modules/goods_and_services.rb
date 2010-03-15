class Modules::GoodsAndServices
  REFINED_MODEL = :refined_goods_and_services_value
  
  def self.pretty_module_name
    "Goods and Services"
  end
  
  # do not modify
  def initialize(calculator_input)
    @calculator_input = calculator_input
  end
  
  def process
    clothing                = self.class.actual_value_for_variable(@calculator_input.user_input, :clothing)
    furnishings             = self.class.actual_value_for_variable(@calculator_input.user_input, :furnishings)
    other_goods             = self.class.actual_value_for_variable(@calculator_input.user_input, :other_goods)
    services                = self.class.actual_value_for_variable(@calculator_input.user_input, :services)
    
    footprint = self.class.result_for_values(
      clothing[:value],
      furnishings[:value],
      other_goods[:value],
      services[:value]
    )
    
    {
      :footprint               => footprint,
      :clothing                => clothing,
      :furnishings             => furnishings,
      :other_goods             => other_goods,
      :services                => services
    }
  end
  
  ###############
  # static ######
  ###############
  
  def self.average_result
    {
      :footprint               => 0,
      :clothing                => {:value => 158, :calculation => :average},
      :furnishings             => {:value => 150, :calculation => :average},
      :other_goods             => {:value => 402, :calculation => :average},
      :services                => {:value => 1052, :calculation => :average}
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
  
  def self.result_for_values(clothing, furnishings, other_goods, services)
    v = ((clothing * 436) + (furnishings * 459) + (other_goods * 338) + (services * 178) * 12)
    v * 0.000001 * 1.10231131 # to metric tons to short tons
  end
  
  def self.possible_inputs
    [
      {:type => :text_field, :name => 'clothing',                 :title => '$ spent on clothing per month'},
      {:type => :text_field, :name => 'furnishings',              :title => '$ spent on furnishings per month'},
      {:type => :text_field, :name => 'other_goods',              :title => '$ spent on other goods per month'},
      {:type => :text_field, :name => 'services',                 :title => '$ spent on other services per month'}
    ]
  end
  
  def self.input_variables_statistics
    possible_inputs.collect { |input_variable|
      max = Rails.cache.fetch("#{self.name}/var/#{input_variable[:name]}/max", :expires_in => 1800) { RefinedGoodsAndServicesValue.maximum(input_variable[:name]) }
      min = Rails.cache.fetch("#{self.name}/var/#{input_variable[:name]}/min", :expires_in => 1800) { RefinedGoodsAndServicesValue.minimum(input_variable[:name]) }
      
      input_variable.merge(
        :maximum => max,
        :minimum => min
      )
    }
  end
  
  def self.average_value_for_input_variable_for_city_state_country(variable, city, state, country)
    Rails.cache.fetch("#{self.name}/var/#{variable}/average", :expires_in => 1800) {
      RefinedGoodsAndServicesValue.average(variable, :include => :query, :conditions => ['queries.city = ? and queries.state = ? and queries.country = ? and ? is not null', city, state, country, variable])
    }
  end
  
  def self.process_input(calculator_input, refined_params)
    if calculator_input.user_input.send(REFINED_MODEL)
      calculator_input.user_input.send(REFINED_MODEL).destroy
    end
    
    RefinedGoodsAndServicesValue.create(
      :query_id                => calculator_input.user_input.id,
      :clothing                => refined_params[:clothing],
      :furnishings             => refined_params[:furnishings],
      :other_goods             => refined_params[:other_goods],
      :services                => refined_params[:services]
    )
  end
end
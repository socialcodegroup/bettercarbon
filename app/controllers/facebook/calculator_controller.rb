class Facebook::CalculatorController < ApplicationController
  ensure_authenticated_to_facebook
  ensure_application_is_installed_by_facebook_user
  
  filter_parameter_logging :fb_sig_friends, :password
  
  layout "facebook"
  
  def index
    @calculator_input = CalculatorInput.new(:facebook => true, :fb_user_id => @facebook_session.user.uid)
    @calculator_result = CarbonCalculator.process(@calculator_input)
    
    possible_inputs_set1 = [:miles_driven, :miles_public_transport, :mpg, :vehicle_size, :water_and_sewage_costs, :square_feet_of_household, :meat_fish_protein, :eat_organic_food, :num_short_trips]
    possible_inputs_set2 = CarbonCalculator.modules.collect{|m|m.possible_inputs.collect{|i|i[:name].to_sym}}.flatten - possible_inputs_set1

    @inputs_set1 = possible_inputs_set1.sort_by{rand}.take(3)
    @inputs_set2 = possible_inputs_set2.sort_by{rand}.take(2)

    @all_allowed_inputs = @inputs_set1 + @inputs_set2
  end
  
  def do_refine
    @calculator_input = CalculatorInput.new(:facebook => true, :fb_user_id => @facebook_session.user.uid)
    @old_calculator_result = CarbonCalculator.process(@calculator_input)
    
    old_mod_results = @old_calculator_result.per_module_results
    stripped_values = strip_existing_values_from_refined_values(old_mod_results, params[:profile])
    
    stripped_values.each do |mod, values|
      mod = CarbonCalculator.modules.select{|c|c.name == mod}.first
      mod.process_input(@calculator_input, values)
    end
    
    @calculator_input.destroy_cache
    @calculator_result = CarbonCalculator.process(@calculator_input)
    @calculator_input.user_input.update_attribute(:algorithmic_footprint, @calculator_result.total_footprint)
  end
  
  private
    
    def strip_existing_values_from_refined_values(cal_mod_results, refined_values)
      filtered_refined_values = {}
      refined_values = {} if refined_values.nil?
      
      refined_values.each do |mod, values|
        specific_cal_mod_results = cal_mod_results.select{|m,v|m.to_s == mod}.first[1]
        values.each do |k, v|
          result = specific_cal_mod_results.select{|var_name, params|var_name.to_s == k}.first
          
          _mod = CarbonCalculator.modules.select{|m|m.to_s == mod}.first
          var_info = _mod.possible_inputs.select{|pi|pi[:name]==k}.first
          
          if var_info[:type] == :text_field
            if ((result[1][:value].to_f - v.to_f).abs >= 0.01) || (result[1][:calculation] == :exact)
              filtered_refined_values[mod] = {} if filtered_refined_values[mod].blank?
              filtered_refined_values[mod][k.to_sym] = v
            end
          elsif var_info[:type] == :select
            if result[1][:value].round != v.to_f.round || (result[1][:calculation] == :exact)
              filtered_refined_values[mod] = {} if filtered_refined_values[mod].blank?
              filtered_refined_values[mod][k.to_sym] = v
            end
          end
        end
      end
      
      filtered_refined_values
    end
end

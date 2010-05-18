class CalculatorController < ApplicationController
  def index
  end
  
  def result
    @calculator_input = CalculatorInput.new(:address => params[:address], :tags => '')
    
    cache_path = "/cached/#{Digest::SHA1.hexdigest(params[:address])}"
    @calculator_result = Rails.cache.fetch(cache_path, :expires_in => 180) {
      CarbonCalculator.process(@calculator_input)
    }
    
    @calculator_input.user_input.update_attribute(:algorithmic_footprint, @calculator_result.total_footprint)
    @old_calculator_result = nil
    
    
    case params[:view]
    when 'details'
      # @pie_graph = open_flash_chart_object(630, 300, "/charts/graph_code?address=#{params[:address]}")
      @partial_for_view = 'details'
    when 'recs'
      # nothing
      @partial_for_view = 'recommendations'
    else
      # @bar_graph = open_flash_chart_object(630, 300, "/charts/graph_code2?address=#{params[:address]}")
      @partial_for_view = 'overview'
      
      city_footprint = Query.sum(:algorithmic_footprint, :conditions => ['country = ? and state = ? and city = ?', 'US', @calculator_input.user_input.state, @calculator_input.user_input.city]).to_f / Query.count(:conditions => ['country = ? and state = ? and city = ?', 'US', @calculator_input.user_input.state, @calculator_input.user_input.city]).to_f
      state_footprint = Query.sum(:algorithmic_footprint, :conditions => ['country = ? and state = ?', 'US', @calculator_input.user_input.state]) / Query.count(:conditions => ['country = ? and state = ?', 'US', @calculator_input.user_input.state])
      country_footprint = Query.sum(:algorithmic_footprint, :conditions => ['country = ?', 'US']) / Query.count(:conditions => ['country = ?', 'US'])
      
      @gvalues = [
          @calculator_result.total_footprint,
          city_footprint,
          state_footprint,
          country_footprint,
          5
        ]
      
      @gkeys = ["\'Your footprint\'", "'#{@calculator_input.user_input.city}'", "'#{@calculator_input.user_input.state}'", "'United States'", "'World'"]
    end
  rescue InvalidInputException => e
    flash[:notice] = "Please provide a specific address (We weren't able to locate the residence)"
    redirect_to root_path
  end
  
  def refine
    @calculator_input = CalculatorInput.new(:address => params[:address], :tags => '')
    
    if !logged_in?
      @not_an_address = @calculator_input.user_input.percision != "address"
      @user = User.new
      session[:return_to] = refine_calculator_path(:address => @calculator_input.address)
      render :action => "not_logged_in"
    elsif @calculator_input.user_input.percision != "address"
      flash[:notice] = "Sorry, you can only view the profile of a household."
      redirect_to(result_calculator_path(:address => params[:address]))
    else
      claimed = ClaimedAddress.find_by_query_id(@calculator_input.user_input.id)
      
      if claimed && claimed.user_id != current_user.id
        flash[:notice] = 'Sorry, someone else has claimed this address.'
        redirect_to(result_calculator_path(:address => params[:address]))
      elsif claimed && claimed.user_id == current_user.id
        cache_path = "/cached/#{Digest::SHA1.hexdigest(params[:address])}"
        @calculator_result = Rails.cache.fetch(cache_path, :expires_in => 180) {
          CarbonCalculator.process(@calculator_input)
        }
        # @calculator_result = CarbonCalculator.process(@calculator_input)
        @calculator_input.user_input.update_attribute(:algorithmic_footprint, @calculator_result.total_footprint)
        @old_calculator_result = nil
      else
        @not_an_address = @calculator_input.user_input.percision != "address"
        session[:return_to] = refine_calculator_path(:address => @calculator_input.address)
        render :action => "claim_address"
      end
    end
  rescue InvalidInputException => e
    flash[:notice] = "Sorry, we weren't able find the location."
    redirect_to root_path
  end
  
  def tags_dropdown
    @tags = Tag.find(:all, :conditions => ['phrase like ?', "%#{params[:q]}%"], :limit => 10)
    @text_field_html_id = params[:element_id]
    @dropdown_html_id = "#{params[:element_id]}-dropdown-options"
    render :layout => false
  end
  
  def module_part_values_form
    @calculator_input = CalculatorInput.new(:address => params[:address], :tags => '')
    @calculator_result = CarbonCalculator.process(@calculator_input)
    m_v = @calculator_result.per_module_results.select{|k,v|k.name == params[:name]}.first
    render :partial => 'module_part_values_form', :locals => {:module_name => m_v[0], :module_values => m_v[1]}
  end
  
  def do_refine
    @calculator_input = CalculatorInput.new(:address => params[:address], :tags => '')
    @old_calculator_result = CarbonCalculator.process(@calculator_input)
    
    cache_path = "/cached/#{Digest::SHA1.hexdigest(params[:address])}"
    Rails.cache.delete(cache_path)
    
    
    puts "---------------------------------------------------------------------------"
    puts "---------------------------------------------------------------------------"
    puts params[:profile].inspect
    puts "---------------------------------------------------------------------------"
    puts "---------------------------------------------------------------------------"
    
    old_mod_results = @old_calculator_result.per_module_results
    stripped_values = strip_existing_values_from_refined_values(old_mod_results, params[:profile])
    
    puts "---------------------------------------------------------------------------"
    puts "---------------------------------------------------------------------------"
    puts stripped_values.inspect
    puts "---------------------------------------------------------------------------"
    puts "---------------------------------------------------------------------------"
    
    
    stripped_values.each do |mod, values|
      mod = CarbonCalculator.modules.select{|c|c.name == mod}.first
      mod.process_input(@calculator_input, values)
    end
    
    @calculator_input.destroy_cache
    @calculator_result = CarbonCalculator.process(@calculator_input)
    @calculator_input.user_input.update_attribute(:algorithmic_footprint, @calculator_result.total_footprint)
    
    redirect_to(result_calculator_path(:address => params[:address]))
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
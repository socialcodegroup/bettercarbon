class Facebook::CalculatorController < ApplicationController
  # SAVE_URL_FOR_ADD_AND_LOGIN_TAG
  # before_filter :redirect_if_auth_key, :except => "master_redirect"
  # REDIRECT_TO_LAST_REQUEST_TAG
  # before_filter :redirect_to_saved, :only => "master_redirect"
  
  
  skip_before_filter :verify_authenticity_token
  filter_parameter_logging :fb_sig_friends, :password
  
  
  # ensure_authenticated_to_facebook
  ensure_application_is_installed_by_facebook_user :except => :hypertree_subtree
  # ensure_application_is_installed_by_facebook_user :only => ["index", "do_refine"]
  
  layout "facebook"
  
  def hypertree_subtree
    params[:calculator_profile] ||= {}
    
    @facebook_session = Facebooker::Session.create
    @facebook_session.secure_with!(params[:fb_sig_session_key], params[:fb_sig_user], 1.hour.from_now)
    
    @calculator_input = CalculatorInput.new(:facebook => true, :fb_user => @facebook_session.user)
    @calculator_result = CarbonCalculator.process(@calculator_input)
    
    
    
    if @facebook_session.user.uid.to_i == params[:node].to_i
      # lookup footprint of friends (who have calculated their footprint)
      @friends_with_app = @facebook_session.user.friends_with_this_app

      @friends_footprints = @friends_with_app.collect { |friend|
        query = Query.find_by_facebook_uid(friend.uid)

        if query
          {
            :friend => friend,
            :footprint => query.algorithmic_footprint
          }
        else
          nil
        end
      }.compact

      footprints = @friends_footprints.collect { |friend_footprint| friend_footprint[:footprint] }
      footprints = footprints + [@calculator_result.total_footprint]

      @max = footprints.max

      @friends_footprints_json = @friends_footprints.collect { |friend_footprint|
        "{'data' : {'$color' : '#{CalcMath::number_to_intensity(friend_footprint[:footprint], 0, @max)}', '$dim' : #{friend_footprint[:footprint].to_i/1.5}},  'id' : '#{friend_footprint[:friend].uid}', 'name' : '#{friend_footprint[:friend].name} - #{sprintf('%.2f', friend_footprint[:footprint])}', 'children' : []}"}
        
        
      @friends_footprints_json << "{'data' : {'$color' : '#ffa500', '$dim' : 20}, 'id' : '-2', 'name' : 'Add a Friend', 'children' : []}"
        
      @friends_footprints_json = @friends_footprints_json.join(',')
        # #{sprintf('%.2f', friend_footprint[:footprint])}

    # friend=<<FRIEND
    #   {
    #     'id' : '#{friend_footprint[:friend].uid}',
    #     'name' : '#{friend_footprint[:friend].name}',
    #     'children' : [],
    #     'data' : {
    #       '$aw' : 20,
    #       '$color' : '#f55'
    #     }
    #   }
    # FRIEND
      # }.join(',')
      
      root_json=<<ROOTJSON
{
  "id": "#{@facebook_session.user.uid}",
  "name": "You",
  "children": [#{@friends_footprints_json}],
  "data": {
    '$dim' : #{@calculator_result.total_footprint.to_i/1.5},
    '$color' : '#{CalcMath::number_to_intensity(@calculator_result.total_footprint, 0, @max)}'
  }
}
ROOTJSON
      
      render :text => root_json
    elsif params[:node].to_i != -1
      @friends_with_app = @facebook_session.user.friends_with_this_app

      @friends_footprints = @friends_with_app.collect { |friend|
        query = Query.find_by_facebook_uid(friend.uid)

        if query
          {
            :friend => friend,
            :footprint => query.algorithmic_footprint
          }
        else
          nil
        end
      }.compact

      footprints = @friends_footprints.collect { |friend_footprint| friend_footprint[:footprint] }
      footprints = footprints + [@calculator_result.total_footprint]

      @max = footprints.max
      
      
      friend_footprint = @friends_footprints.find{|ff| ff[:friend].uid.to_i == params[:node].to_i }
      
      fb_average_footprint = Query.sum(:algorithmic_footprint, :conditions => ['facebook_uid is not null']) / Query.count(:all, :conditions => ['facebook_uid is not null'])
      bettercarbon_average_footprint = Query.sum(:algorithmic_footprint) / Query.count(:all)
      world_average_footprint = 5
      
      root_json=<<ROOTJSON
{
  'data' : {
    '$color' : '#{CalcMath::number_to_intensity(friend_footprint[:footprint], 0, @max)}',
    '$dim' : #{friend_footprint[:footprint].to_i/1.5}
  },
  'id' : '#{params[:node].to_i}',
  'name' : '#{friend_footprint[:friend].name} - #{sprintf('%.2f', friend_footprint[:footprint])}',
  'children' : [
    {
      "id": "#{@facebook_session.user.uid}",
      "name": "You",
      "children": [],
      "data": {
        '$dim' : #{@calculator_result.total_footprint.to_i/1.5},
        '$color' : '#{CalcMath::number_to_intensity(@calculator_result.total_footprint, 0, @max)}'
      }
    },
    {
      'id' : '-1_fb_avg',
      'name' : 'Facebook Average Footprint - #{sprintf('%.2f', fb_average_footprint)}',
      'children' : [],
      'data' : {
        '$color' : '#{CalcMath::number_to_intensity(fb_average_footprint, 0, @max)}',
        '$dim' : #{fb_average_footprint.to_i/1.5}
      }
    },
    {
      'id' : '-1_bettercarbon_avg',
      'name' : 'Better Carbon Avg Footprint - #{sprintf('%.2f', bettercarbon_average_footprint)}',
      'children' : [],
      'data' : {
        '$color' : '#{CalcMath::number_to_intensity(bettercarbon_average_footprint, 0, @max)}',
        '$dim' : #{bettercarbon_average_footprint.to_i/1.5}
      }
    },
    {
      'id' : '-1_world_avg',
      'name' : 'World Avg Footprint - #{sprintf('%.2f', world_average_footprint)}',
      'children' : [],
      'data' : {
        '$color' : '#{CalcMath::number_to_intensity(world_average_footprint, 0, @max)}',
        '$dim' : #{world_average_footprint.to_i/1.5}
      }
    }
  ]
}
ROOTJSON
      render :text => root_json
    else
      render :nothing => true
    end
  end
  
  def framed_visualization
    params[:calculator_profile] ||= {}
    
    @calculator_input = CalculatorInput.new(:facebook => true, :fb_user => @facebook_session.user)
    @old_calculator_result = CarbonCalculator.process(@calculator_input)

    old_mod_results = @old_calculator_result.per_module_results
    stripped_values = strip_existing_values_from_refined_values(old_mod_results, params[:calculator_profile][:profile])

    stripped_values.each do |mod, values|
      mod = CarbonCalculator.modules.select{|c|c.to_s.gsub(':', '') == mod}.first
      mod.process_input(@calculator_input, values)
    end

    @calculator_input.destroy_cache
    @calculator_result = CarbonCalculator.process(@calculator_input)
    @calculator_input.user_input.update_attribute(:algorithmic_footprint, @calculator_result.total_footprint)

    average_footprint = Query.sum(:algorithmic_footprint) / Query.count(:all)

    @gvalues = [
        @calculator_result.total_footprint,
        average_footprint,
        5
      ]

    @gkeys = ["\'Your footprint\'", "\'Average Footprint\'", "'World'"]

    # lookup footprint of friends (who have calculated their footprint)
    @friends_with_app = facebook_session.user.friends_with_this_app

    @friends_footprints = @friends_with_app.collect { |friend|
      query = Query.find_by_facebook_uid(friend.uid)

      if query
        {
          :friend => friend,
          :footprint => query.algorithmic_footprint
        }
      else
        nil
      end
    }.compact

    footprints = @friends_footprints.collect { |friend_footprint| friend_footprint[:footprint] }
    footprints = footprints + [@calculator_result.total_footprint]

    @max = footprints.max

    @friends_footprints_json = @friends_footprints.collect { |friend_footprint|
      "{'data' : {'$color' : '#{CalcMath::number_to_intensity(friend_footprint[:footprint], 0, @max)}', '$dim' : #{friend_footprint[:footprint].to_i/1.5}},  'id' : '#{friend_footprint[:friend].uid}', 'name' : '#{friend_footprint[:friend].name} - #{sprintf('%.2f', friend_footprint[:footprint])}', 'children' : []}"
      # #{sprintf('%.2f', friend_footprint[:footprint])}

  # friend=<<FRIEND
  #   {
  #     'id' : '#{friend_footprint[:friend].uid}',
  #     'name' : '#{friend_footprint[:friend].name}',
  #     'children' : [],
  #     'data' : {
  #       '$aw' : 20,
  #       '$color' : '#f55'
  #     }
  #   }
  # FRIEND
    }
    
    @friends_footprints_json << "{'data' : {'$color' : '#ffa500', '$dim' : 20}, 'id' : '-2', 'name' : 'Add a Friend', 'children' : []}"
    
    @friends_footprints_json = @friends_footprints_json.join(',')
    
    render :layout => false
  end
  
  def calculate
    @calculator_input = CalculatorInput.new(:facebook => true, :fb_user => @facebook_session.user)
    @calculator_result = CarbonCalculator.process(@calculator_input)
    
    possible_inputs_set1 = [:miles_driven, :miles_public_transport, :mpg, :vehicle_size, :water_and_sewage_costs, :square_feet_of_household, :meat_fish_protein, :eat_organic_food, :num_short_trips]
    possible_inputs_set2 = CarbonCalculator.modules.collect{|m|m.possible_inputs.collect{|i|i[:name].to_sym}}.flatten - possible_inputs_set1

    @inputs_set1 = possible_inputs_set1.sort_by{rand}[0..2]
    @inputs_set2 = possible_inputs_set2.sort_by{rand}[0..1]

    @all_allowed_inputs = @inputs_set1 + @inputs_set2
    
    respond_to do |format|
      format.fbml
    end
  end
  
  def calculate_full
    @calculator_input = CalculatorInput.new(:facebook => true, :fb_user => @facebook_session.user)
    @calculator_result = CarbonCalculator.process(@calculator_input)
    
    @all_inputs_are_allowed = true
    
    respond_to do |format|
      format.fbml
    end
  end
  
  def do_refine
    params[:calculator_profile] ||= {}
    
    @calculator_input = CalculatorInput.new(:facebook => true, :fb_user => @facebook_session.user)
    @old_calculator_result = CarbonCalculator.process(@calculator_input)
    
    old_mod_results = @old_calculator_result.per_module_results
    stripped_values = strip_existing_values_from_refined_values(old_mod_results, params[:calculator_profile][:profile])
    
    stripped_values.each do |mod, values|
      mod = CarbonCalculator.modules.select{|c|c.to_s.gsub(':', '') == mod}.first
      mod.process_input(@calculator_input, values)
    end
    
    @calculator_input.destroy_cache
    @calculator_result = CarbonCalculator.process(@calculator_input)
    @calculator_input.user_input.update_attribute(:algorithmic_footprint, @calculator_result.total_footprint)
    
    average_footprint = Query.sum(:algorithmic_footprint) / Query.count(:all)
    
    @gvalues = [
        @calculator_result.total_footprint,
        average_footprint,
        5
      ]
    
    @gkeys = ["\'Your footprint\'", "\'Average Footprint\'", "'World'"]
    
    # lookup footprint of friends (who have calculated their footprint)
    @friends_with_app = facebook_session.user.friends_with_this_app
    
    @friends_footprints = @friends_with_app.collect { |friend|
      query = Query.find_by_facebook_uid(friend.uid)
      
      if query
        {
          :friend => friend,
          :footprint => query.algorithmic_footprint
        }
      else
        nil
      end
    }.compact
    
    footprints = @friends_footprints.collect { |friend_footprint| friend_footprint[:footprint] }
    footprints = footprints + [@calculator_result.total_footprint]
    
    @max = footprints.max
    
    @friends_footprints_json = @friends_footprints.collect { |friend_footprint|
      "{'data' : {'$color' : '#{CalcMath::number_to_intensity(friend_footprint[:footprint], 0, @max)}', '$dim' : #{friend_footprint[:footprint].to_i/1.5}},  'id' : '#{friend_footprint[:friend].uid}', 'name' : '#{friend_footprint[:friend].name} - #{sprintf('%.2f', friend_footprint[:footprint])}', 'children' : []}"
      # #{sprintf('%.2f', friend_footprint[:footprint])}
      
# friend=<<FRIEND
#   {
#     'id' : '#{friend_footprint[:friend].uid}',
#     'name' : '#{friend_footprint[:friend].name}',
#     'children' : [],
#     'data' : {
#       '$aw' : 20,
#       '$color' : '#f55'
#     }
#   }
# FRIEND
    }.join(',')
    
    if request.post?
    #   redirect_to('/bettercarbon/invites/new')
      begin
        facebook_session.user.publish_activity({ :message => '{actor} calculated their footprint on Better Carbon.', :action_link => { :text => 'Calculate your footprint', :href => 'bettercarbon/' }})
        FacebookerPublisher.deliver_news_feed(facebook_session.user, " Better Carbon Calculator", " Calculated their footprint on Better Carbon, calculate your own footprint here.")
        FootprintPublisher.deliver_calculate_feed(facebook_session)
      rescue Exception => e
        RAILS_DEFAULT_LOGGER.error e
      end
    end
    
    # FacebookerPublisher.deliver_templatized_news_feed(facebook_session.user)
  end
  
  def publish_to_friends
    acct_array = []
    BcPublisher.deliver_notification(acnt_array, @facebook_session.user)
  end
  
  private
    
    def strip_existing_values_from_refined_values(cal_mod_results, refined_values)
      filtered_refined_values = {}
      refined_values = {} if refined_values.nil?
      
      refined_values.each do |mod, values|
        specific_cal_mod_results = cal_mod_results.select{|m,v|m.to_s.gsub(':', '') == mod}.first[1]
        values.each do |k, v|
          result = specific_cal_mod_results.select{|var_name, params|var_name.to_s == k}.first
          
          _mod = CarbonCalculator.modules.select{|m|m.to_s.gsub(':', '') == mod}.first
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
    
    # def redirect_if_auth_key
    #   if( params[:auth_token])
    #     redirect_to( url_for("/facebook/calculator") )
    #     return false
    #   else
    #     # RAILS_DEFAULT_LOGGER.error params[:controller].inspect
    #     # RAILS_DEFAULT_LOGGER.error "---"
    #     # RAILS_DEFAULT_LOGGER.error params[:action].inspect
    #     # cookies[:last_request] = master_redirect_calculator_url(:canvas => true)
    #     return true
    #   end
    # end
    
    # def redirect_to_saved
    #   redirect_to( cookies[:last_request] || url_for("/")) and return false
    # end  
    
    def set_facebook_params
      @fb_params = params.inject({}) do |collection, pair|
        collection[pair.first] = pair.second if pair.first =~ /^fb_sig/
        collection
      end
    end
end

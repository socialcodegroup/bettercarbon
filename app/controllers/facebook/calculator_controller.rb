class Facebook::CalculatorController < ApplicationController
  ensure_authenticated_to_facebook
  ensure_application_is_installed_by_facebook_user
  
  filter_parameter_logging :fb_sig_friends, :password
  
  layout "facebook"
  
  def index
    @user = current_user(:facebook => true)
    # render :text => facebook_session.user.name
  end
end

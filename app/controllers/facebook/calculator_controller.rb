class Facebook::CalculatorController < ApplicationController
  ensure_application_is_installed_by_facebook_user
  
  layout "facebook"
  
  def index
    # render :text => facebook_session.user.name
  end
end

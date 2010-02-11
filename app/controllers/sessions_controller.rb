# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # render new.rhtml
  def new
    @session = Session.new
  end

  def create
    logout_keeping_session!
    
    params[:session] ||= {}
    user = User.authenticate(params[:session][:email], params[:session][:password])
    
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:session][:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      if current_user.claimed_addresses.count > 0
        redirect_back_or_default(result_calculator_path(:address => current_user.claimed_addresses.first.query.input))
      else
        redirect_back_or_default(root_path)
      end
      flash[:notice] = "Logged in successfully"
    else
      note_failed_signin
      @session = Session.new(:email => params[:session][:email])
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end

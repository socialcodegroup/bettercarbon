class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]
    
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    @user.password_confirmation = params[:user][:password]
    if @user.save
      if @user.address.blank?
        redirect_back_or_default('/')
      else
        redirect_back_or_default(result_calculator_path(:address => @user.address))
      end
    else
      render :action => :new
    end
  end
  
  def show
    @user = @current_user
    render :action => :edit
  end

  def edit
    @user = @current_user
  end
  
  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      @user.claimed_addresses.each{|a|a.destroy}
      (params[:claimed_addresses]||[]).each do |i, claimed_address|
        calculator_input = CalculatorInput.new(:address => claimed_address[:address], :tags => '') rescue nil

        if calculator_input && ["address", "zip+4"].include?(calculator_input.user_input.percision)
          calculator_input.user_input.update_attribute(:suggestion, claimed_address[:suggestion])
          claimed_address = ClaimedAddress.create(:query_id => calculator_input.user_input.id, :user_id => current_user.id)
        end
      end
      
      flash[:notice] = "Account updated!"
      redirect_to(root_path)
    else
      render :action => :edit
    end
  end
  
  def forgot
    if request.post?
      user = User.find_by_email(params[:user][:email])
      if user
        user.create_reset_code
        flash[:notice] = "Reset code sent to #{user.email}"
      else
        flash[:notice] = "#{params[:user][:email]} does not exist in system"
      end
      redirect_back_or_default('/')
    else
      @user = User.new
    end
  end

  def reset
    @user = User.find_by_reset_code(params[:reset_code]) unless params[:reset_code].nil?
    if request.post?
      if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password])
        self.current_user = @user
        @user.delete_reset_code
        flash[:notice] = "Password reset successfully for #{@user.email}"
        redirect_back_or_default('/')
      else
        render :action => :reset
      end
    end
  end
end




# class UsersController < ApplicationController
#   def new
#     @user = User.new
#   end
#  
#   def create
#     logout_keeping_session!
#     
#     user = User.authenticate(params[:user][:email], params[:user][:password])
#     if user
#       self.current_user = user
#       new_cookie_flag = true
#       handle_remember_cookie! new_cookie_flag
#       if current_user.address.blank?
#         redirect_back_or_default('/')
#       else
#         redirect_back_or_default(result_calculator_path(:address => current_user.address))
#       end
#     else
#       @user = User.new(params[:user])
#       @user.password_confirmation = params[:user][:password]
#       success = @user && @user.save
#       if success && @user.errors.empty?
#         # Protects against session fixation attacks, causes request forgery
#         # protection if visitor resubmits an earlier form using back
#         # button. Uncomment if you understand the tradeoffs.
#         # reset session
#         self.current_user = @user # !! now logged in
#         if @user.address.blank?
#           redirect_back_or_default('/')
#         else
#           redirect_back_or_default(result_calculator_path(:address => @user.address))
#         end
#         # flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
#       else
#         flash[:error]  = "We couldn't set up that account, sorry."
#         render :action => 'new'
#       end
#     end
#   end
#   
#   def edit
#     @user = current_user
#   end
#   
#   def update
#     if current_user.update_attributes(params[:user])
#       # success
#     else
#       flash[:notice] = "Something went wrong!"
#     end
#     
#     redirect_to(edit_user_path)
#   end
#   
#   
#   
#   def forgot
#     if request.post?
#       user = User.find_by_email(params[:user][:email])
#       if user
#         user.create_reset_code
#         flash[:notice] = "Reset code sent to #{user.email}"
#       else
#         flash[:notice] = "#{params[:user][:email]} does not exist in system"
#       end
#       redirect_back_or_default('/')
#     else
#       @user = User.new
#     end
#   end
# 
#   def reset
#     @user = User.find_by_reset_code(params[:reset_code]) unless params[:reset_code].nil?
#     if request.post?
#       if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password])
#         self.current_user = @user
#         @user.delete_reset_code
#         flash[:notice] = "Password reset successfully for #{@user.email}"
#         redirect_back_or_default('/')
#       else
#         render :action => :reset
#       end
#     end
#   end
# end

class ClaimedAddressesController < ApplicationController
  before_filter :require_user
  
  def create
    @calculator_input = CalculatorInput.new(:address => params[:claimed_address], :tags => '')
    
    if ["address", "zip+4"].include?(@calculator_input.user_input.percision)
      @claimed_address = ClaimedAddress.create(:query_id => @calculator_input.user_input.id, :user_id => current_user.id)
      redirect_to(refine_calculator_path(:address => @calculator_input.address))
    else
      flash[:notice] = 'There was a problem claiming this address'
      redirect_to(result_calculator_path(:address => @calculator_input.address))
    end
  rescue InvalidInputException => e
    flash[:notice] = "Please provide a specific address (We weren't able to locate the residence)"
    redirect_to root_path
  end
end
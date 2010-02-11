class StaticController < ApplicationController
  def twitter_user
    @twitter_user = params[:twitter_user]
  end
end

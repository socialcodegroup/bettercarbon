class Facebook::InvitesController < ApplicationController
  ensure_authenticated_to_facebook
  ensure_application_is_installed_by_facebook_user
  
  skip_before_filter :verify_authenticity_token
  
  filter_parameter_logging :fb_sig_friends, :password
  
  layout "facebook"
  
  def index
    redirect_to('/bettercarbon/calculator/do_refine')
  end
  
  def new
    @from_user_id = facebook_session.user.to_s
  end
  
  def create
    
#     message = <<-MESSAGE
# <fb:fbml> Calculate your carbon footprint using your social graph!
# <a href="http://apps.facebook.com/bettercarbon/"> Go!</a>
# </fb:fbml>
# MESSAGE
    
    @sent_to_ids = params[:ids]
    
    # facebook_session.send_notification(@sent_to_ids, message)
    
    redirect_to('/bettercarbon/calculator/do_refine')
  end
  
  # def select
  #   fql =  "SELECT uid, name FROM user WHERE uid IN" +
  #   "(SELECT uid2 FROM friend WHERE uid1 = #{@current_fb_user_id}) " +
  #   "AND has_added_app = 0" 
  #   xml_friends = fbsession.fql_query :query => fql
  #   @friends = Hash.new
  #   xml_friends.search("//user").map do|usrNode| 
  #     @friends[(usrNode/"uid").inner_html] = (usrNode/"name").inner_html
  #   end
  #   render_facebook
  # end
  # 
  # def send_invites
  #   invite = render_to_string(:partial => 'facebook/invites/invite_fbml', :locals => { :inviter => @current_fb_user_id })
  # 
  #   friends = params[:friends]
  #   if friends.is_a? String
  #     invitees = friends
  #   else
  #     invitees = friends.values.join(",")
  #   end
  # 
  #   result_xml = fbsession.notifications_sendRequest(:to_ids => invitees, :type => 'Social Recipe', :content => invite, :invite => true, :image => "http://apps.facebook.com/socialrecipe/P1010825_tiny.jpg")
  # 
  #   response = CGI.unescapeHTML((result_xml/"notifications_sendrequest_response").inner_html)
  # 
  #   if response =~ /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
  #     #need to do a confirmation redirect
  #     if in_facebook_canvas?
  #       render :text => "<fb:redirect url=\"#{response}\"/>", :layout => false
  #     else
  #       redirect_to response
  #     end
  #   else
  #     flash[:notice] = 'Invites sent.'
  #     redirect_to :controller => 'recipes', :action => 'index'
  #   end
  # end
end

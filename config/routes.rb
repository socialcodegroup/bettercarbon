ActionController::Routing::Routes.draw do |map|
  map.logout '/logout', :controller => 'user_sessions', :action => 'destroy'
  map.login '/login', :controller => 'user_sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.forgot '/forgot', :controller => 'users', :action => 'forgot'
  map.reset 'reset/:reset_code', :controller => 'users', :action => 'reset'
    
  # map.resources :charts
  map.resources :users
  map.resource :user_session
  map.resources :claimed_addresses
  
  map.namespace :facebook do |facebook|
    facebook.resource :invites
  end
  
  # The priority is based upon order of creation: first created -> highest priority.
  
  map.resource :calculator, :collection => {:result => :get, :refine => :get}, :controller => 'calculator'
  
  
  map.how_it_works  '/how_it_works', :controller => 'static', :action => 'how_it_works'
  map.faq           '/faq', :controller => 'static', :action => 'faq'
  map.what_i_can_do '/what_i_can_do', :controller => 'static', :action => 'what_i_can_do'
  map.contact       '/contact', :controller => 'static', :action => 'contact'
  
  map.profile_lookup '/profile_lookup/:twitter_user', :controller => 'static', :action => 'twitter_user'
  
  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "calculator"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end

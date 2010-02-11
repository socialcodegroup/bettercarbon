require 'mongrel_cluster/recipes'

#========================
#CONFIG
#========================
set :application, "bettercarbon"

set :scm, :git
# set :git_enable_submodules, 1
#set :deploy_via, :remote_cache
set :repository,  "git@github.com:socialcodegroup/bettercarbon.git"
set :branch, "master"
set :ssh_options, { :forward_agent => true }

set :stage, :production
set :user, "deploy"
set :use_sudo, false
set :runner, "deploy"
set :deploy_to, "/u/apps/#{stage}/#{application}"
set :mongrel_conf, "#{deploy_to}/current/config/mongrel_cluster.yml"
set :mongrel_servers, 3
set :mongrel_port, 9000
set :mongrel_environment, 'production'
#========================
#ROLES
#========================
role :app, "75.101.157.229"
role :web, "75.101.157.229"
role :db,  "75.101.157.229", :primary => true
set :rails_env, "production"

#========================
#CUSTOM
#========================
namespace :deploy do
  task :after_setup, :role => :app do
    run "cd #{shared_path} && mkdir config"
  end
  
  task :after_symlink, :role => :app do
    mongrel.cluster.configure
  end
  
  # task :after_deploy_cold, :role => :app do
  #   run "cd #{current_path} && rake ts:index RAILS_ENV=production"
  # end
  # 
  
  
  # task :after_restart, :role => :app do
  #   # run "cd #{current_path} && rake ts:config RAILS_ENV=production"
  #   # run "cd #{current_path} && rake ts:run RAILS_ENV=production"
  #   run "cd #{current_path} && RAILS_ENV=production script/delayed_job restart"
  # end
  # 
  # task :after_stop, :role => :app do
  #   # run "cd #{current_path} && rake ts:stop RAILS_ENV=production"
  #   run "cd #{current_path} && RAILS_ENV=production script/delayed_job stop"
  # end
  # 
  # task :after_start, :role => :app do
  #   # run "cd #{current_path} && rake ts:config RAILS_ENV=production"
  #   # run "cd #{current_path} && rake ts:run RAILS_ENV=production"
  #   run "cd #{current_path} && RAILS_ENV=production script/delayed_job start"
  #   run "cd #{current_path} && rake delayed_job:install_initial"
  # end
end
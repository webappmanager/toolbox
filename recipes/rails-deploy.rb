# Uncomment if you are using Rails' asset pipeline
load 'deploy/assets'

# Recipe to deploy Rails applications using Webappmanager
require 'bundler/capistrano'

# Application configuration
set :application, wam['app']['name']
set :rails_env, wam['app']['rails_env'] || "development"

# Version control system (:git,:svn...) configuration
set :scm, wam['app']['repository_type'] || ':git'
set :scm_user, wam['app']['repository_user'] unless wam['app']['repository_user'].nil?
set :scm_password, wam['app']['repository_password'] unless wam['app']['repository_password'].nil?
set :repository, wam['app']['repository_location']
set :branch, wam['app']['repository_branch'] || 'master'

# Deploy transfer configuration (target path, user/password, ssh) 
set :deploy_to, wam['app']['deploy_path'] 
set :user, wam['app']['deploy_user'] unless wam['app']['deploy_user'].nil?
set :password, wam['app']['deploy_password'] unless wam['app']['deploy_password'].nil?
set :deploy_via, wam['app']['deploy_via'] || 'remote_cache'
set :copy_cache, "/tmp/cap-deploy-cache/#{application}"
set :copy_exclude, [".git", ".DS_Store", ".gitignore", ".gitmodules", ".svn", "**/.svn"]

set :use_sudo, false

# avoid asset warnings during deploys
set :normalize_asset_timestamps, false

# Run ssh-add and enable ssh agent forwarding
#`ssh-add`
# set :ssh_options, { :forward_agent => true }

# Retrieve servers linked to the application and add to the recipe
unless wam['app']['servers'].nil?
  logger.info("Adding Servers");
  wam['app']['servers'].each do |s|
    logger.info("Server:  #{s['address']}  Roles:  #{s['roles']}");
    server s['address'], *eval(s['roles'])
  end
end

namespace :deploy do
  desc "Link shared files and directories / Install gems"
  task :run_after_update do
    # Link release directories to shared directories
    logger.info("Creating links for shared resources");
    dir_list = ["vendor/bundle", "db/store"]
    run dir_list.map{|d| "mkdir -p #{shared_path}/#{d} && ln -nfs #{shared_path}/#{d} #{release_path}/#{d}"}.join("; ")

    # replace built-in bundler call
    # logger.info("Installing bundler");
    # run "cd #{current_path} && bundle install --deployment"
    
    # migrate the db
    # run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake db:migrate"
    
  end
  task :link_db do
    logger.info("Creating link for database.yml");
    run "ln -nfs #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
  end
  before "deploy:assets:precompile", "deploy:link_db"
end




# Setup installation directory if first deploy
after "deploy:update", "deploy:run_after_update"
#after "deploy", "deploy:migrate"
after "deploy", "deploy:cleanup"
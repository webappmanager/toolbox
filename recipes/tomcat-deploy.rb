# Recipe: tomcat-deploy
# Deploy packaged tomcat server with included applications
 
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
  wam['app']['servers'].each do |s|
    server s['address'], s['roles']
  end
end

# Avoid shared directory links
set :shared_children, ["logs"]

# Setup installation directory if first deploy
after "deploy", "deploy:cleanup"
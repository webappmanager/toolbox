# Recipe to manage ssh keys on remote servers for a given application

# Application configuration
set :ssh_key_public, wam['ssh_keys']['public']
set :user, wam['app']['deploy_user'] unless wam['app']['deploy_user'].nil?
set :password, wam['app']['deploy_password'] unless wam['app']['deploy_password'].nil?

set :use_sudo, false

# Retrieve servers linked to the application and add to the recipe
unless wam['app']['servers'].nil?
  wam['app']['servers'].each do |s|
    server s['address'], *s['roles']
  end
end

namespace :ssh_keys do
  desc "Copy id_rsa.pub to remote servers under .ssh/authorized_keys"
  task :copy_public do
    # Copy ssh keys to remote server
    run "echo  '#{ssh_key_public}' >> .ssh/authorized_keys"
  end
end
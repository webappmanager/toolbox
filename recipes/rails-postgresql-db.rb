# Application configuration
set :application, wam['app']['name']
set :rails_env, wam['app']['rails_env'] || "development"
set :shared_path, wam['app']['deploy_path'] + "/shared"
 
set :db_user, wam['app']['db_user']
set :db_password, wam['app']['db_password']
set :development_db, wam['app']['name'] + "_development"
set :test_db,  wam['app']['name'] + "_test"
set :production_db, wam['app']['name'] + "_production"

# Retrieve servers linked to the application and add to the recipe
unless wam['app']['servers'].nil?
  wam['app']['servers'].each do |s|
    server s['address'], *s['roles']
  end
end

namespace :postgresql_db do
  desc "Create database yaml in shared path"
  task :configure do
    db_config = <<-EOF
base: &base
  adapter: postgresql
  encoding: utf8
  username: #{db_user}
  password: #{db_password}
 
development:
  database: #{development_db}
  <<: *base
 
test:
  database: #{test_db}
  <<: *base
 
production:
  database: #{production_db}
  <<: *base
    EOF
 
    run "mkdir -p #{shared_path}/config"
    put db_config, "#{shared_path}/config/database.yml"
  end
 
  desc "Make symlink for database yaml"
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{latest_release}/config/database.yml"
  end
end

before "deploy:setup", "postgresql_db:configure"
after "deploy:update_code", "postgresql_db:symlink"
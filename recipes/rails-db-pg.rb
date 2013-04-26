# Shared variables for db
set :db_user, wam['app']['db_user']
set :db_password, wam['app']['db_password']
set :db_name, wam['app']['db_name']
set :db_encoding, wam['app']['db_encoding'] || "unicode"
set :rails_env, rails_env || wam['app']['rails_env']

# Specific to PostgreSQL
set :db_permissions, wam['app']['db_permissions'] || "createdb"
set :pg_service, wam['app']['pg_service'] || "postgresql-9.2"

namespace :db do
    namespace :pg do

      desc "Create database yaml in shared path"
      task :configure do
     
        run "mkdir -p #{shared_path}/config"
        db_config = {
          rails_env => {
            "adapter"  => "postgresql",
            "template" => "template0",
            "encoding" => db_encoding,
            "database" => db_name,
            "username" => db_user,
            "password" => db_password } }
        
        # Copy the database.yml file to application shared space
        puts "    ↑ Uploading #{shared_path}/config/database.yml"
        put db_config.to_yaml, "#{shared_path}/config/database.yml", :roles => :app, :mode => "0750"
        puts "    Done"

        # Create new role in postgresql with permissions
        run "sudo -u postgres psql -c \"DROP ROLE IF EXISTS #{db_user}; CREATE ROLE #{db_user} WITH #{db_permissions} LOGIN PASSWORD '#{db_password}'; ALTER ROLE #{db_user} LOGIN; \"", :roles => :db
      end
     
      desc "Make symlink for database yaml"
      task :symlink do
        run "ln -nfs #{shared_path}/config/database.yml #{current_path}/config/database.yml"
      end
      
      desc "Restart the database"
      task :restart do
        run "sudo service #{pg_service} restart", :roles => :db
      end

      desc "Rebuild the database"
      task :rebuild do
        restart
        puts "    Deleting and rebuilding database for #{current_path}"
        run "cd #{current_path} && RAILS_ENV=#{rails_env} bundle exec rake #{[:drop, :create, :migrate, :seed].map{|a| 'db:' + a.to_s}.join(' ')}", :roles => :app
        puts "    Done"
      end
  end

end

before "deploy:setup", "db:pg:configure"
before "deploy:assets:precompile", "db:pg:symlink"
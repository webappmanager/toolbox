# Performs database backup using mysqldump in an application shared directory
# Adapted from http://36zeroes.blogspot.com/2011/11/backup-database-before-deployment-using.html

# Application configuration
set :application, wam['app']['name']
set :db_user, wam['app']['db_user']
set :db_pass, wam['app']['db_pass']
set :db_name, wam['app']['db_name']

namespace :mysql do
  desc "Backup database with mysqldump in app shared directory"

  task :backup, :roles => :db, :only => { :primary => true } do
    run "mkdir -p #{shared_path}/backups"
    filename = "#{application}.db_backup.#{Time.now.to_f}.sql.bz2"
    filepath = "#{shared_path}/backups/#{filename}"

    on_rollback { run "rm #{filepath}" }

    run "mysqldump -u#{db_user} -p#{db_pass} #{db_name} | bzip2 -c > #{filepath}"
  end
end

before :deploy, 'mysql:backup'

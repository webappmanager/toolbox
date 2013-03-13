# Performs backup using mysqldump in an application shared directory
 
# Application configuration
set :application, wam['app']['name']
namespace :mysql do
  desc "Backup database"
 
  task :backup, :roles => :db, :only => { :primary => true } do
    filename = "#{application}.db_backup.#{Time.now.to_f}.sql.bz2"
    filepath = "#{shared_path}/#{filename}"
    text = capture "cat #{deploy_to}/current/config/database.yml"
    yaml = YAML::load(text)
 
    on_rollback { run "rm #{filepath}" }
    run "mysqldump -u #{yaml['production']['username']} -p #{yaml['production']['database']} | bzip2 -c > #{filepath}" do |ch, stream, out|
      ch.send_data "#{yaml['production']['password']}\n" if out =~ /^Enter password:/
    end
  end
end

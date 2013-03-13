# Restart passenger by performing touch tmp/restart.txt in the root of Rails application.
# Include this recipe with your deploy want to restart passenger after deploy

namespace :passenger do
  desc "Restart the application"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
 
after "deploy", "passenger:restart"

# Recipe: tomcat-deploy-restart
# Include this recipe to start and stop tomcat server during deploy for java applications

namespace :tomcat do
  desc "Restart the application"
  task :stop, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path}/bin && ./shutdown.sh || true"
  end
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path}/bin && ./startup.sh"
  end
end
 
before "deploy", "tomcat:stop"
after "deploy", "tomcat:start"
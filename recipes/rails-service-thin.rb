# Include this recipe to start and stop thin web server during deploy for rails applications

namespace :thin do
  desc "Restart the application"
  task :stop, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && bundle exec thin stop || true"
  end
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && bundle exec thin start -e #{rails_env} -d #{wam['app']['listen_port'] && '-p ' + wam['app']['listen_port']}"
  end
end
 
before "deploy", "thin:stop"
after "deploy", "thin:start"

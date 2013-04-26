# Provision server using chef-solo command and a repository with 
# all the required cookbooks and recipes. Repository should contain
# solo.rb file at the root and following optional properties:
#   chef_solo_args - optional arguments to chef-solo command.  Ex: -l debug -o recipe[rails-app]
#   chef_json_attr - optional attributes in JSON format.  Ex: { "run_list": ["recipe[postgresql::server]", "recipe[nginx::source]"] }
#
# solo.rb example: 
# ---------------
# cookbook_path File.expand_path("../cookbooks", __FILE__)
# json_attribs File.expand_path("../node.json", __FILE__)


require 'json'

set :user, wam['server']['chef_user'] || "root"
set :password, wam['server']['deploy_password'] unless wam['server']['deploy_password'].nil?

set :scm, wam['server']['repository_type'] || 'git'
set :repository, wam['server']['chef_repo']
set :branch, wam['server']['repository_branch'] || 'master'
set :deploy_to, wam['server']['deploy_path'] || '/tmp/chef'

set :deploy_via, wam['server']['deploy_via'] || 'copy'
set :copy_exclude, [".git", ".DS_Store", ".gitignore", ".gitmodules", ".svn", "**/.svn"]
set :use_sudo, false
#set :copy_cache, "/tmp/cap-deploy-cache/#{application}"

#replace default args - but take care to remember to use absolute paths for solo.rb 
set :chef_solo_args, wam['server']['chef_solo_args']
set :json_attr, wam['server']['chef_json_attr']
#set :run_list, wam['server']['chef_run_list']

#server wam['server']['address'], eval(wam['server']['roles'])
server wam['server']['address'], :app


namespace :chef do
  desc "Execute chef-solo command to provistion a server"
  task :provision do
    run "curl -L http://opscode.com/chef/install.sh | bash"
    
    if json_attr
      #Create json_attr_file
      json_attr_file = File.join(current_path, "wam_node.json")
      put json_attr, json_attr_file, :roles => :app, :mode => "0750"
    end
    #run "ln -nfs #{current_path} /var/chef"
    #run "ls -altr /var/chef"
    #run "cd /var/chef && chef-solo -c /var/chef/solo.rb #{' -j ' + json_attr if json_attr} #{' -o ' + run_list if run_list}"
    
    json_attr_args = jason_attr.nil? ? "-j #{json_attr_file}" : ""
    chef_solo_args ||= "-c #{current_path}/solo.rb #{json_attr_args && json_attr_args} #{chef_solo_args && chef_solo_args}"
    
    run "cd #{current_path} && chef-solo #{chef_solo_args}"
  end
end

before "deploy", "deploy:setup"
before "chef:provision", "deploy"


# Use scp during deployment instead of sftp
# Deployment uses SFTP by default when you use deploy_via :copy.
# If you don't run SFTP on your servers, use SCP instead.
 
module UseScpForDeployment
  def self.included(base)
    base.send(:alias_method, :old_upload, :upload)
    base.send(:alias_method, :upload,     :new_upload)
  end
 
  def new_upload(from, to)
    old_upload(from, to, :via => :scp)
  end
end
Capistrano::Configuration.send(:include, UseScpForDeployment)

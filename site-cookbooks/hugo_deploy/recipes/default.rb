
current_user = 'ubuntu'
appname = node[:hugo][:app][:name]
app_branch = node[:hugo][:app][:branch] if node[:hugo][:app][:branch]
repo_url = (node[:hugo][:app][:repo] || "#{node[:github][:url]}/#{appname}.git")

directory "/home/#{current_user}/apps/#{appname}" do
  owner "#{current_user}"
  group "#{current_user}"
  action :create
  recursive true
end

['config', 'log','pids'].each do |d|
  directory "/home/#{current_user}/apps/#{appname}/shared/#{d}" do
    owner "#{current_user}"
    group "#{current_user}"
    action :create
    recursive true
  end
end


if node[:database] and node[:database][:name]
  ### Do Database config
  template "/home/#{current_user}/apps/#{appname}/shared/config/database.yml" do
    owner "#{current_user}"
    group "#{current_user}"
    source "database.erb"
  end
    
end

### Apache Config
template "/home/#{current_user}/apps/#{appname}/shared/config/apache2.conf" do
  owner "#{current_user}"
  group "#{current_user}"  
  source "vhost.erb"
end


deploy "/home/#{current_user}/apps/#{appname}" do
  repo repo_url
  user node[:hugo][:app][:user] || "#{current_user}"
  branch app_branch || "HEAD"
  environment node[:hugo][:app][:environment] || "production"
  if node[:hugo][:app][:restart_command]
    restart_command node[:hugo][:app][:restart_command]  
  else
    restart_command "touch tmp/restart.txt"
  end
  shallow_clone node[:hugo][:app][:shallow_clone] || true
  if node[:hugo][:app][:migrate]
    migrate node[:hugo][:app][:migrate]
  else
    migrate false
  end
  if node[:hugo][:app][:migration_command]
    migration_command node[:hugo][:app][:migration_command]
  else
    migration_command "rake db:migrate"
  end
  enable_submodules node[:hugo][:app][:enable_submodules] || true
  action node[:hugo][:app][:action] || :deploy
end

# execute "ln" do
#   command "ln -nsf /home/#{current_user}/apps/#{appname}/shared/config/database.yml /home/#{current_user}/apps/#{appname}/current/config/database.yml"
#   action :run
# end


if node[:hugo][:app][:ssl]
  raise StandardError.new("APP URL is required!") unless node[:hugo][:app][:url]
  raise StandardError.new("SSL PUBLIC is required!") unless node[:hugo][:app][:ssl][:public]
  raise StandardError.new("SSL PRIVATE is required!") unless node[:hugo][:app][:ssl][:private]
  
   
  ### Apache SSL Public Key
  template "/etc/ssl/certs/#{node[:hugo][:app][:url]}.crt" do
    owner "root"
    group "root"  
    source "publickey.erb"
  end

  ### Apache SSL Private Key
  template "/etc/ssl/certs/#{node[:hugo][:app][:url]}.key" do
    owner "root"
    group "root"  
    source "privatekey.erb"
  end

  ### Apache GD Bundle
  template "/etc/ssl/certs/gd_bundle.crt" do
    owner "root"
    group "root"  
    source "gd_bundle.erb"
  end if node[:hugo][:app][:ssl][:gd_bundle]
end

file "/etc/apache2/sites-enabled/000-default" do
  action :delete
end

execute "ln" do
  command "sudo ln -nsf /home/#{current_user}/apps/#{appname}/shared/config/apache2.conf /etc/apache2/sites-enabled/#{appname}"
  action :run
end



execute "ln" do
  command "ln -nsf /home/#{current_user}/apps/#{appname}/shared/log /home/#{current_user}/apps/#{appname}/current/log"
  action :run
end


#
# execute "/etc/init.d/apache2" do
#   command "/etc/init.d/apache2 restart"
#   action :run
# end

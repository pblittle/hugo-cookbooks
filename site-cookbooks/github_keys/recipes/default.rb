current_user = 'ubuntu'

directory '/home/#{current_user}/.ssh' do
  owner "#{current_user}"
  group "#{current_user}"
  mode "0700"
  action :create
  recursive true
end

template "/home/#{current_user}/.ssh/id_rsa" do
  owner "#{current_user}"
  group "#{current_user}"
  mode "0600"
  source "privatekey.erb"
  variables :privatekey => node[:github][:privatekey]
  not_if { File.exists?("/home/#{current_user}/.ssh/id_rsa") }
end

template "/home/#{current_user}/.ssh/id_rsa.pub" do
  owner "#{current_user}"
  group "#{current_user}"
  mode "0600"
  source "publickey.erb"
  variables :publickey => node[:github][:publickey]
  not_if { File.exists?("/home/#{current_user}/.ssh/id_rsa.pub") }
end

template "/home/#{current_user}/.ssh/config" do
  owner "#{current_user}"
  group "#{current_user}"
  mode "0600"
  source "config.erb"
  variables :application => node[:application]
  not_if { File.exists?("/home/#{current_user}/.ssh/config") }
end

# template "/home/#{current_user}/.ssh/known_hosts" do
#   owner "#{current_user}"
#   group "#{current_user}"
#   mode "0600"
#   source "known_hosts.erb"
#   variables :known_hosts => node[:ssh][:known_hosts]
# end

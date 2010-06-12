ssh_username = node[:ssh_username]

directory '/home/#{ssh_username}/.ssh' do
  owner "#{ssh_username}"
  group "#{ssh_username}"
  mode "0700"
  action :create
  recursive true
end

template "/home/#{ssh_username}/.ssh/id_rsa" do
  owner "#{ssh_username}"
  group "#{ssh_username}"
  mode "0600"
  source "privatekey.erb"
  variables :privatekey => node[:github][:privatekey]
  not_if { File.exists?("/home/#{ssh_username}/.ssh/id_rsa") }
end

template "/home/#{ssh_username}/.ssh/id_rsa.pub" do
  owner "#{ssh_username}"
  group "#{ssh_username}"
  mode "0600"
  source "publickey.erb"
  variables :publickey => node[:github][:publickey]
  not_if { File.exists?("/home/#{ssh_username}/.ssh/id_rsa.pub") }
end

template "/home/#{ssh_username}/.ssh/config" do
  owner "#{ssh_username}"
  group "#{ssh_username}"
  mode "0600"
  source "config.erb"
  variables :application => node[:application]
  not_if { File.exists?("/home/#{ssh_username}/.ssh/config") }
end

# template "/home/#{ssh_username}/.ssh/known_hosts" do
#   owner "#{ssh_username}"
#   group "#{ssh_username}"
#   mode "0600"
#   source "known_hosts.erb"
#   variables :known_hosts => node[:ssh][:known_hosts]
# end

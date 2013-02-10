directory "/var/lib/ejabberd" do
  owner "ejabberd"
  group "ejabberd"
  mode "700"
end

file "/var/lib/ejabberd/.erlang.cookie" do
  content node[:ejabberd_erlang_cookie]
  owner "ejabberd"
  group "ejabberd"
  mode "600"
end

package "ejabberd"

service "ejabberd" do
  start_command "/etc/init.d/ejabberd start"
  stop_command "/etc/init.d/ejabberd stop"
end

execute "wait for ejabberd to start, so we can stop it" do
  command "until ejabberdctl status; do sleep 1; done"
end

service "ejabberd" do
  action :stop
  not_if { File.exist?("/var/lib/ejabberd/.configured") }
end

# yeah this recipe is super dangerous, but we need to clear
# out the data created when the service started without
# all the config we need.
execute "clean ejabberd dir" do
  command "rm /var/lib/ejabberd/[!.]*"
  not_if { File.exist?("/var/lib/ejabberd/.configured") }
end

template "/etc/default/ejabberd" do
  source "ejabberd.erb"
  mode "644"
end

template "/etc/ejabberd/ejabberd.cfg" do
  source "ejabberd.cfg.erb"
  group "ejabberd"
  mode "640"
  variables(:jabber_domain => node[:jabber_domain])
  notifies :restart, resources(:service => "ejabberd")
end

if node[:ejabberd_replicate_from]

  template "/tmp/ejabberd_add_to_cluster.erl" do
    source "ejabberd_add_to_cluster.erl.erb"
    mode "700"
    owner "ejabberd"
    group "ejabberd"
    not_if { File.exist?("/var/lib/ejabberd/.configured") }
  end

  execute "add to cluster" do
    group "ejabberd"
    user "ejabberd"
    command "/tmp/ejabberd_add_to_cluster.erl #{node[:ejabberd_replicate_from]}"
    not_if { File.exist?("/var/lib/ejabberd/.configured") }
  end

end

# for some reason, chef seems to think that ejabberd is already running here
execute "start ejabberd" do
  command "/etc/init.d/ejabberd start"
  not_if { File.exist?("/var/lib/ejabberd/.configured") }
end

# this is our marker that says the initial round of setup is done. (ick)
file "/var/lib/ejabberd/.configured" do
  content "done"
end

execute "wait for ejabberd to start" do
  command "until ejabberdctl status; do sleep 1; done"
end

if !node[:ejabberd_replicate_from]

  # only run this on the main node
  execute "add ejabberd admin user" do
    command "/usr/sbin/ejabberdctl register admin #{node[:jabber_domain]} #{node[:jabber_admin_password]}"
  end

end

package "ejabberd" do
  # This version of ejabberd does not start on installation.
  # When ejabberd starts, it writes things to local storage
  # that make it hard to change its domain name later.
  version "2.1.11-1insops~precise2"
end

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

service "ejabberd" do
  start_command "/etc/init.d/ejabberd start"
  stop_command "/etc/init.d/ejabberd stop"
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
  template "/usr/sbin/ejabberd_mnesia_info.erl" do
    source "ejabberd_mnesia_info.erl.erb"
    mode "700"
    owner "ejabberd"
    group "ejabberd"
  end

  template "/usr/sbin/ejabberd_add_to_cluster.erl" do
    source "ejabberd_add_to_cluster.erl.erb"
    mode "700"
    owner "ejabberd"
    group "ejabberd"
  end

  # TODO: only run this when ejabberd is stopped
  execute "add to cluster" do
    group "ejabberd"
    user "ejabberd"
    command "/usr/sbin/ejabberd_add_to_cluster.erl #{node[:ejabberd_replicate_from]}"
    # attempt to only run this if running db nodes only has 1 item
    only_if do
      !File.exist?("/var/lib/ejabberd/.configured")
      # TODO: make this work, being smarter about checking if the db is already clustered
      #str = `/usr/sbin/ejabberd_mnesia_info.erl | grep "running db nodes"`.chomp
      #puts "str: #{str}"
      #str =~ /\[(.*)\]/
      #nodes = $1.split(',')
      #nodes.length == 1
    end
  end

  file "/var/lib/ejabberd/.configured" do
    content "done"
  end
end

# for some reason, chef seems to think that ejabberd is already running here
execute "start ejabberd" do
  command "/etc/init.d/ejabberd start"
  not_if "ejabberdctl status"
end

execute "wait for ejabberd to start" do
  command "until ejabberdctl status; do sleep 1; done"
  timeout 30
end

if !node[:ejabberd_replicate_from]
  # only run this on the main node
  execute "add ejabberd admin user" do
    command "/usr/sbin/ejabberdctl register admin #{node[:jabber_domain]} #{node[:jabber_admin_password]}"
    only_if do
      `ejabberdctl registered_users #{node[:jabber_domain]} | grep admin | wc -l`.chomp.to_i == 0
    end
  end
end


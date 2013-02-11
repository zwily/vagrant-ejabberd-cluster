package "vim"

execute "apt-get update" do
  command "apt-get update"
  action :none
end

cookbook_file "/etc/apt/sources.list.d/instructure.list" do
  notifies :run, "execute[apt-get update]", :delayed
end

cookbook_file "/etc/apt/trusted.gpg.d/apt.insops.net.gpg" do
  notifies :run, "execute[apt-get update]", :delayed
end


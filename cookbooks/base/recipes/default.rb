package "vim"

execute "apt-get update" do
  command "apt-get update"
  action :nothing
end

cookbook_file "/etc/apt/trusted.gpg.d/apt.insops.net.gpg"
cookbook_file "/etc/apt/sources.list.d/instructure.list" do
  notifies :run, "execute[apt-get update]", :immediate
end


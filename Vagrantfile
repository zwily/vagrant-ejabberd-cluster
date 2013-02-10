# -*- mode: ruby -*-
# vi: set ft=ruby :

nodes = {
  :node1 => {
    :hostnames => [ "chat1.example.com", "chat1" ],
    :ip_address => "192.168.50.51",
  },
  :node2 => {
    :hostnames => [ "chat2.example.com", "chat2" ],
    :ip_address => "192.168.50.52",
    :replicate_from => "ejabberd@chat1.example.com",
  },
}

Vagrant::Config.run do |config|
  config.vm.box = "precise"
  config.vm.box_url = "http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-vagrant-amd64-disk1.box"

  config.vm.customize ["modifyvm", :id, "--memory", 1024]

  nodes.each do |name, info|
    config.vm.define name do |node_config|
      node_config.vm.network :hostonly, info[:ip_address]
      node_config.vm.host_name = info[:hostnames].first
      node_config.hosts.aliases = info[:hostnames][1..-1] if info[:hostnames].length > 1

      node_config.vm.provision :chef_solo do |chef|
        chef.json = {
          :jabber_domain => 'example.com',
          :jabber_admin_password => 'password',
          :ejabberd_erlang_cookie => 'mycookieyum',
          :ejabberd_replicate_from => info[:replicate_from],
        }
        chef.add_recipe("base")
        chef.add_recipe("ejabberd")
      end
    end
  end
end

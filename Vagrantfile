# -*- mode: ruby -*-
# vi: set ft=ruby :
# vi: set tabstop=2 :

nodes = {
  :node1 => {
    :hostnames  => ['chat1.example.com', 'chat1'],
    :ip_address => '192.168.50.51',
  },
  :node2 => {
    :hostnames      => ['chat2.example.com', 'chat2'],
    :ip_address     => '192.168.50.52',
    :replicate_from => 'ejabberd@chat1.example.com',
  },
}

Vagrant.require_plugin('vagrant-hostmanager')

Vagrant.configure('2') do |config|
  config.vm.box = 'precise64'
  config.vm.box_url = 'http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-vagrant-amd64-disk1.box'

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true

  config.vm.provider 'virtualbox' do |v|
    v.customize ['modifyvm', :id, '--cpus', '2']
    v.customize ['modifyvm', :id, '--memory', '512']
  end

  nodes.each do |name, info|
    config.vm.define name do |node_config|
      node_config.vm.network :private_network, ip: info[:ip_address]
      node_config.vm.hostname = info[:hostnames].first
      node_config.hostmanager.aliases = info[:hostnames].last

      node_config.vm.provision :chef_solo do |chef|
        chef.json = {
          :jabber_domain           => 'example.com',
          :jabber_admin_password   => 'password',
          :ejabberd_erlang_cookie  => 'mycookieyum',
          :ejabberd_replicate_from => info[:replicate_from],
        }
        chef.add_recipe('base')
        chef.add_recipe('ejabberd')
      end
    end
  end
end

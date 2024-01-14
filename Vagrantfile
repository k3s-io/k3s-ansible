# encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

# ENV['VAGRANT_NO_PARALLEL'] = 'no'
NODE_ROLES = ["server-0", "agent-0", "agent-1"]
NODE_BOXES = ['generic/ubuntu2004', 'generic/ubuntu2004', 'generic/ubuntu2004']
NODE_CPUS = 2
NODE_MEMORY = 3000
# Virtualbox >= 6.1.28 requires expand private networks: "cat '* 0.0.0.0/0 ::/0' >> /etc/vbox/network.conf".
NETWORK_PREFIX = "10.10.10"

CURRENT_DIR = File.dirname(File.expand_path(__FILE__))
DEFAULT_EXTRA_VARS = YAML.load_file("#{CURRENT_DIR}/group_vars/all/vars.yml")

def provision(vm, role, node_num)
  vm.box = NODE_BOXES[node_num]
  vm.hostname = role
  # We use a private network because the default IPs are dynamically assigned 
  # during provisioning. This makes it impossible to know the server-0 IP when 
  # provisioning subsequent servers and agents. A private network allows us to
  # assign static IPs to each node, and thus provide a known IP for the API endpoint.
  node_ip = "#{NETWORK_PREFIX}.#{100+node_num}"
  # An expanded netmask is required to allow VM<-->VM communication, virtualbox defaults to /32
  vm.network "private_network", ip: node_ip, netmask: "255.255.255.0"

  if node_num == NODE_ROLES.length() - 1
    host_vars = {}

    NODE_ROLES.each_with_index do |name, i|
      host_vars[name] = {
        external_host: "#{NETWORK_PREFIX}.#{100+i}",
        extra_server_args: "--node-external-ip #{NETWORK_PREFIX}.#{100+i} --flannel-iface eth1", 
        extra_agent_args: "--node-external-ip #{NETWORK_PREFIX}.#{100+i} --flannel-iface eth1 --node-label 'role=storage-node'"
      }
    end

    vm.provision "ansible", run: 'once' do |ansible|
      ansible.limit = "all,localhost"
      ansible.compatibility_mode = "2.0"
      ansible.playbook = "playbook/site.yml"
      ansible.groups = {
        "server" => NODE_ROLES.grep(/^server/),
        "agent" => NODE_ROLES.grep(/^agent/),
        "k3s_cluster:children" => ["server", "agent"],
      }
      ansible.host_vars = host_vars
      ansible.extra_vars = DEFAULT_EXTRA_VARS.merge({
        k3s_version: "v1.28.5+k3s1",
        api_endpoint: NODE_ROLES.grep(/^server/)[0],
        token: "myvagrant",
        # Required to use the private network configured above
        
        # Optional, left as reference for ruby-ansible syntax
        # extra_service_envs: [ "NO_PROXY='localhost'" ],
        # server_config_yaml: <<~YAML
        #   write-kubeconfig-mode: 644
        #   kube-apiserver-arg:
        #     - advertise-port=1234
        # YAML
      })
    end
  end
end

Vagrant.configure("2") do |config|
  # Default provider is libvirt, virtualbox is only provided as a backup
  config.vm.provider "libvirt" do |v|
    v.cpus = NODE_CPUS
    v.memory = NODE_MEMORY
  end
  config.vm.provider "virtualbox" do |v|
    v.cpus = NODE_CPUS
    v.memory = NODE_MEMORY
    v.linked_clone = true
  end
  
  NODE_ROLES.each_with_index do |name, i|
    config.vm.define name do |node|
      provision(node.vm, name, i)
    end
  end
end
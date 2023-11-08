# ENV['VAGRANT_NO_PARALLEL'] = 'no'
NODE_ROLES = ["server-0", "server-1", "server-2", "agent-0", "agent-1"]
NODE_BOXES = ['generic/ubuntu2004', 'generic/ubuntu2004', 'generic/ubuntu2004', 'generic/ubuntu2004', 'generic/ubuntu2004']
NODE_CPUS = 2
NODE_MEMORY = 2048
# Virtualbox >= 6.1.28 require `/etc/vbox/network.conf` for expanded private networks 
NETWORK_PREFIX = "10.10.10"

def provision(vm, role, node_num)
  vm.box = NODE_BOXES[node_num]
  vm.hostname = role
  # An expanded netmask is required to allow VM<-->VM communication, virtualbox defaults to /32
  node_ip = "#{NETWORK_PREFIX}.#{100+node_num}"
  vm.network "private_network", ip: node_ip, netmask: "255.255.255.0"

  vm.provision "ansible", run: 'once' do |ansible|
    ansible.compatibility_mode = "2.0"
    ansible.verbose = "vv"
    ansible.playbook = "playbook/site.yml"
    ansible.groups = {
      "server" => NODE_ROLES.grep(/^server/),
      "agent" => NODE_ROLES.grep(/^agent/),
      "k3s_cluster:children" => ["server", "agent"],
    }
    ansible.extra_vars = {
      k3s_version: "v1.26.5+k3s1",
      api_endpoint: "#{NETWORK_PREFIX}.100",
      api_port: 6443,
      extra_server_args: "",
      extra_server_init_args: "",
      extra_agent_args: "",
    }
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
  end
  
  # Must iterate on the index, vagrant does not understand iterating 
  # over the node roles themselves
  NODE_ROLES.each_with_index do |name, i|
    config.vm.define name do |node|
      provision(node.vm, name, i)
    end
  end

end

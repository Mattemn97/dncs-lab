Vagrant.configure("2") do |config|
  config.vm.box_check_update = false
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--usb", "on"]
    vb.customize ["modifyvm", :id, "--usbehci", "off"]
    vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
    vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
    vb.customize ["modifyvm", :id, "--nicpromisc4", "allow-all"]
    vb.customize ["modifyvm", :id, "--nicpromisc5", "allow-all"]
    vb.memory = 256
    vb.cpus = 1
  end
  config.vm.define "router-1" do |router1|
    router1.vm.box = "minimal/trusty64"
    router1.vm.hostname = "router-1"
    router1.vm.network "private_network", virtualbox__intnet: "broadcast_router-south-1", auto_config: false
    router1.vm.network "private_network", virtualbox__intnet: "broadcast_router-inter", auto_config: false
    router1.vm.provision "shell", path: "router-1.sh"
  end
  config.vm.define "router-2" do |router2|
    router2.vm.box = "minimal/trusty64"
    router2.vm.hostname = "router-2"
    router2.vm.network "private_network", virtualbox__intnet: "broadcast_router-south-2", auto_config: false
    router2.vm.network "private_network", virtualbox__intnet: "broadcast_router-inter", auto_config: false
    router2.vm.provision "shell", path: "router-2.sh"
  end
  config.vm.define "switch" do |switch|
    switch.vm.box = "minimal/trusty64"
    switch.vm.hostname = "switch"
    switch.vm.network "private_network", virtualbox__intnet: "broadcast_router-south-1", auto_config: false
    switch.vm.network "private_network", virtualbox__intnet: "broadcast_host_a", auto_config: false
    switch.vm.network "private_network", virtualbox__intnet: "broadcast_host_b", auto_config: false
    switch.vm.provision "shell", path: "switch.sh"
  end
  config.vm.define "host-A-1" do |hosta|
    hosta.vm.box = "minimal/trusty64"
    hosta.vm.hostname = "host-A-1"
    hosta.vm.network "private_network", virtualbox__intnet: "broadcast_host_a", auto_config: false
    hosta.vm.provision "shell", path: "host-A-1.sh"
  end
  config.vm.define "host-B-1" do |hostb|
    hostb.vm.box = "minimal/trusty64"
    hostb.vm.hostname = "host-B-1"
    hostb.vm.network "private_network", virtualbox__intnet: "broadcast_host_b", auto_config: false
    hostb.vm.provision "shell", path: "host-B-1.sh"
  end
  config.vm.define "host-C-2" do |hostc|
    hostc.vm.box = "ubuntu/xenial64"
    hostc.vm.hostname = "host-C-2"
    hostc.vm.network "private_network", virtualbox__intnet: "broadcast_router-south-2", auto_config: false
    hostc.vm.provision "shell", path: "host-C-2.sh"
  end
end

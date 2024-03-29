# DNCS-LAB | Assignment

_Author_: **Filippini Matteo** Mat. 186426

_Description_: This repository contains the Vagrant files and the scripts required to run the virtual lab environment used in the DNCS course.

_Assignment_: Based the Vagrantfile and the provisioning scripts available at: https://github.com/dustnic/dncs-lab the candidate is required to design a functioning network where any host configured and attached to router-1 (through switch) can browse a website hosted on host-C-2.
The subnetting needs to be designed to accommodate the following requirement (no need to create more hosts than the one described in the vagrantfile):
- Up to 130 hosts in the same subnet of host-A-1
- Up to 25 hosts in the same subnet of host-B-1
- Consume as few IP addresses as possible

## First start

-   Install Virtualbox 
-   Install Vagrant
-   Open the terminal and execute the command: `git clone https://github.com/mattemn97/dncs-lab`
-   You should be able to launch the lab from within the cloned repo folder.
  ```
    cd dncs-lab
    [~/dncs-lab] vagrant up --provision
  ```

Once you launch the vagrant script, it may take a while for the entire topology to become available.

-   Verify the status of the 6 VMs
  ```
    [dncs-lab]$ vagrant status  
    Current machine states:
    router-1                  running (virtualbox)
    router-2                  running (virtualbox)
    switch                    running (virtualbox)
    host-A-1                  running (virtualbox)
    host-B-1                  running (virtualbox)
    host-C-2                  running (virtualbox)
  ```
-   Once all the VMs are running verify you can log into all of them:
  ```
    vagrant ssh router-1
    vagrant ssh router-2
    vagrant ssh switch
    vagrant ssh host-A-1
    vagrant ssh host-B-1
    vagrant ssh host-C-2
  ```
  To log out use the command `exit`

-   to test reachability log into `host-C-2` and try to ping `host-B-1` with `ping 10.0.20.1`

  ```bash
    [dncs-lab]$ vagrant ssh host-C-2
    vagrant@host-C-2: ping 10.0.20.1
  ```
and vice versa:
  ```bash
    [dncs-lab]$ vagrant ssh host-B-1
    vagrant@host-B-1: ping 10.0.80.1
  ```
-   Get the webpage from `host-C-2` with `curl 10.0.80.1`
  ```bash
    vagrant@host-B-1: curl 10.0.80.1
  ```



## Requirements

-   10GB disk storage
-   2GB free RAM
-   Virtualbox (<https://www.virtualbox.org>)
-   Vagrant (<https://www.vagrantup.com>)
-   Internet

### Network map

    VAGRANT
    MANAGEMENT

     +------+
     |      |
     |      +---------------------------------------------+
     |      |                                         eth0|
     |      |           +--------+                    +--------+
     |      |           |        |                    |        |
     |      |       eth0|        |                    |        |
     |      +-----------+ROUTER 1+-------------------->ROUTER 2|
     |      |           |        |eth2            eth2|        |
     |      |           |        |                    |        |
     |      |           +--------+                    +--------+
     |      |               |eth1                           |eth1
     |      |               |                               |
     |      |               |eth1                           |eth1
     |      |       +-------v--------+                  +---v--+
     |      |       |                |                  |      |
     |      |   eth0|    SWITCH      |                  |      |
     |      +-------+                |                  |HOST C|
     |      |       |                |                  |      |
     |      |       +----------------+                  +------+
     |      |           |eth2     |eth3                    |eth0
     |      |           |eth1     |eth1                    |
     |      |       +---v--+  +---v--+                     |
     |      |       |      |  |      |                     |
     |      |   eth0|      |  |      |                     |
     |      +-------+HOST A|  |HOST B|                     |
     |      |       |      |  |      |                     |
     |      |       +------+  +-+----+                     |
     |      |                   | eth0                     |
     |      +-------------------+                          |
     |      +----------------------------------------------+
     +------+

### Subnets

The network is divided in 4 different subnets:

-   **A** including `host-A-1` and `router-1`. The subnet is a /24 so you can get IP addresses for 2<sup>32-24</sup>-2 = 254 different hosts (130 minimum required)

-   **B** including `host-A-1` and `router-1`. The subnet is a /27 so you can get IP addresses for 2<sup>32-27</sup>-2 = 30 different hosts (25 minimum required)

-   **C** including `router-1` and `router-2`. The subnet is a /30 so you can get IP addresses for 2<sup>32-30</sup>-2 = 2 different hosts

-   **D** including `router-2` and `host-C-2`. The subnet is a /30 so you can get IP addresses for 2<sup>32-30</sup>-2 = 2 different hosts

### VLANs

Two different VLANs allow `router-1` to connect two different subnets via unique port. This two VLANs are marked with VIDs:

| VID | Subnet |
| --- | ------ |
| 50  | A      |
| 20  | B      |

### Interface-IP mapping

| Device   | Interface | IP                | Subnet |
| -------- | --------- | ----------------- | ------ |
| host-A-1 | eth1      | 10.0.50.1/24      | A      |
| router-1 | eth1.50   | 10.0.50.254/24    | A      |
| host-B-1 | eth1      | 10.0.20.1/27      | B      |
| router-1 | eth1.20   | 10.0.20.30/27     | B      |
| host-C-2 | eth1      | 10.0.80.1/30      | C      |
| router-2 | eth1      | 10.0.80.2/30      | C      |
| router-1 | eth2      | 172.16.255.253/30 | D      |
| router-2 | eth2      | 172.16.255.254/30 | D      |


### Vagrant file and provisioning scripts

The project folder contains the Vagrant file, used to set up all the Virtual Machines, and the provisioning scripts for each VM.

All the VMs are based on Trusty64, an exception is made for host-C-2, based on Xenial64. This is because of a recent update of Docker, not supported by Trusty64's kernel.

#### Router 1

Router 1 is a VM based on Trusty64. Here the code used in the Vagrantfile to create the VM with two different interfaces.
  ```ruby
    config.vm.define "router-1" do |router1|
      router1.vm.box = "minimal/trusty64"
      router1.vm.hostname = "router-1"
      router1.vm.network "private_network", virtualbox__intnet: "broadcast_router-south-1", auto_config: false
      router1.vm.network "private_network", virtualbox__intnet: "broadcast_router-inter", auto_config: false
      router1.vm.provision "shell", path: "router-1.sh"
    end
  ```
This code will execute the provisioning script named "router-1.sh"

The following lines are used to configure a trunk port for the VLAN:
  ```bash
    ip link add link eth1 name eth1.50 type vlan id 50
    ip link add link eth1 name eth1.20 type vlan id 20
  ```
Then is possible to assign IP addresses:
  ```bash
    ip addr add 10.0.50.254/24 dev eth1.50
    ip addr add 10.0.20.30/27 dev eth1.20
    ip addr add 172.16.255.253/30 dev eth2
  ```
Lastly the IP forwarding using OSPF
  ```bash
    sysctl net.ipv4.ip_forward=1
    sed -i 's/zebra=no/zebra=yes/g' /etc/frr/daemons
    sed -i 's/ospfd=no/ospfd=yes/g' /etc/frr/daemons
    service frr restart
    vtysh -c 'configure terminal' -c 'interface eth2' -c 'ip ospf area 0.0.0.0'
    vtysh -c 'configure terminal' -c 'router ospf' -c 'redistribute connected'
  ```

#### Router 2

Router 2 is a VM based on Trusty64. Here the code used in the Vagrantfile to create the VM with two different interfaces.
  ```ruby
    config.vm.define "router-2" do |router2|
      router2.vm.box = "minimal/trusty64"
      router2.vm.hostname = "router-2"
      router2.vm.network "private_network", virtualbox__intnet: "broadcast_router-south-2", auto_config: false
      router2.vm.network "private_network", virtualbox__intnet: "broadcast_router-inter", auto_config: false
      router2.vm.provision "shell", path: "router-2.sh"
    end
  ```
This code will execute the provisioning script named "router-2.sh"

The following lines are used to configure IP addresses:
  ```bash
    ip addr add 10.0.80.2/30 dev eth1
    ip addr add 172.16.255.254/30 dev eth2
  ```
Then the IP forwarding using OSPF
  ```bash
  sysctl net.ipv4.ip_forward=1
  sed -i 's/zebra=no/zebra=yes/g' /etc/frr/daemons
  sed -i 's/ospfd=no/ospfd=yes/g' /etc/frr/daemons
  service frr restart
  vtysh -c 'configure terminal' -c 'interface eth2' -c 'ip ospf area 0.0.0.0'
  vtysh -c 'configure terminal' -c 'router ospf' -c 'redistribute connected'
  ```

#### Switch

Switch is a VM based on Trusty64. Here the code used in the Vagrantfile to create the VM with three different interfaces.
  ```ruby
    config.vm.define "switch" do |switch|
      switch.vm.box = "minimal/trusty64"
      switch.vm.hostname = "switch"
      switch.vm.network "private_network", virtualbox__intnet: "broadcast_router-south-1", auto_config: false
      switch.vm.network "private_network", virtualbox__intnet: "broadcast_host_a", auto_config: false
      switch.vm.network "private_network", virtualbox__intnet: "broadcast_host_b", auto_config: false
      switch.vm.provision "shell", path: "switch.sh"
  end
  ```
This code will execute the provisioning script named "switch.sh"

The following lines are used to set up a bridge (named switch) and add the interfaces to it (_eth1_ and _eth2_ are used for VLAN):
  ```bash
    ovs-vsctl add-br switch
    ovs-vsctl add-port switch eth1
    ovs-vsctl add-port switch eth2 tag=50
    ovs-vsctl add-port switch eth3 tag=20
  ```
Then the last command to set up ovs-system:
  ```bash
    ip link set dev ovs-system up
  ```

#### Host A

Host A is a VM based on Trusty64. Here the code used in the Vagrantfile to create the VM with one interface, connected to the _switch_.
  ```ruby
    config.vm.define "host-A-1" do |hosta|
      hosta.vm.box = "minimal/trusty64"
      hosta.vm.hostname = "host-A-1"
      hosta.vm.network "private_network", virtualbox__intnet: "broadcast_host_a", auto_config: false
      hosta.vm.provision "shell", path: "host-A-1.sh"
    end
  ```
This code will execute the provisioning script named "host-A-1.sh"

The following line is used to configure the IP address on _eth1_:
  ```bash
    ip addr add 10.0.50.1/24 dev eth1
  ```
Then is possible to set a static route to _router-1_:
  ```bash
    ip route add 10.0.0.0/8 via 10.0.50.254
  ```


#### Host B

Host B is a VM based on Trusty64. Here the code used in the Vagrantfile to create the VM with one interface, connected to the _switch_.
  ```ruby
    config.vm.define "host-B-1" do |hostb|
      hostb.vm.box = "minimal/trusty64"
      hostb.vm.hostname = "host-B-1"
      hostb.vm.network "private_network", virtualbox__intnet: "broadcast_host_b", auto_config: false
      hostb.vm.provision "shell", path: "host-B-1.sh"
    end
  ```
This code will execute the provisioning script named "host-B-1.sh"

The following line is used to configure the IP address on _eth1_:
  ```bash
    ip addr add 10.0.20.1/27 dev eth1
  ```
Then is possible to set a static route to _router-1_:
  ```bash
    ip route add 10.0.0.0/8 via 10.0.20.30
  ```

#### Host C

Host C is a VM based on Xenial64. Here the code used in the Vagrantfile to create the VM with one interface, connected to the _router-2_.
  ```ruby
    config.vm.define "host-C-2" do |hostc|
      hostc.vm.box = "ubuntu/xenial64"
      hostc.vm.hostname = "host-C-2"
      hostc.vm.network "private_network", virtualbox__intnet: "broadcast_router-south-2", auto_config: false
      hostc.vm.provision "shell", path: "host-C-2.sh"
    end
  ```
This code will execute the provisioning script named "host-C-2.sh"

The following line is used to configure the IP address on _enp0s8_:
  ```bash
    ip addr add 10.0.80.1/30 dev enp0s8
  ```
Then is possible to set a static route to _router-2_:
  ```bash
    ip route add 10.0.0.0/8 via 10.0.80.2
  ```
Lastly the configuration of Docker to create a webserver based on Nginx and a webpage located in _/docker-nginx/html_ directory.
  ```bash
    docker pull nginx
    mkdir -p ~/docker-nginx/html
    echo "<html>
    <head><title>DNCS ASSIGNMENT</title></head>
    <body>
    <p>If you are reading this. We have done all correctly.<p>
    </body>
    </html>" > ~/docker-nginx/html/index.html
    docker run --name docker-nginx -p 80:80 -d -v ~/docker-nginx/html:/usr/share/nginx/html nginx
  ```


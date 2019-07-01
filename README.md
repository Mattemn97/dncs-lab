# DNCS-LAB | Assignment

_Author_: **Filippini Matteo** Mat. 186426

_Description_: This repository contains the Vagrant files and the scripts required to run the virtual lab environment used in the DNCS course.

_Assignment_: Based the V​agrantfile ​and the provisioning scripts available at: https://github.com/dustnic/dncs-lab​ the candidate is required to design a functioning network where any host configured and attached to​ r​outer-1​ (through ​switch​) can browse a website hosted on host-C-2.
The subnetting needs to be designed to accommodate the following requirement (no need to create more hosts than the one described in the vagrantfile):
- Up to 130 hosts in the same subnet of ​host-A-1
- Up to 25 hosts in the same subnet of h​ost-B-1
- Consume as few IP addresses as possible


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


## First start

-   Install Virtualbox 
-   Install Vagrant
-   Open the terminal and execute the command: `git clone https://github.com/Mattemn97/dncs-lab`
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
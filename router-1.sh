export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y tcpdump apt-transport-https ca-certificates curl software-properties-common --assume-yes --force-yes
wget -O- https://apps3.cumulusnetworks.com/setup/cumulus-apps-deb.pubkey | apt-key add -
add-apt-repository "deb [arch=amd64] https://apps3.cumulusnetworks.com/repos/deb $(lsb_release -cs) roh-3"
apt-get update
apt-get install -y frr --assume-yes --force-yes
ip link add link eth1 name eth1.50 type vlan id 50
ip link add link eth1 name eth1.20 type vlan id 20
ip addr add 10.0.50.254/24 dev eth1.50
ip addr add 10.0.20.30/27 dev eth1.20
ip addr add 172.16.255.253/30 dev eth2
ip link set eth1 up
ip link set eth1.50 up
ip link set eth1.20 up
ip link set eth2 up
sysctl net.ipv4.ip_forward=1
sed -i 's/zebra=no/zebra=yes/g' /etc/frr/daemons
sed -i 's/ospfd=no/ospfd=yes/g' /etc/frr/daemons
service frr restart
vtysh -c 'configure terminal' -c 'interface eth2' -c 'ip ospf area 0.0.0.0'
vtysh -c 'configure terminal' -c 'router ospf' -c 'redistribute connected'
clear
echo "End of ROUTER-1"

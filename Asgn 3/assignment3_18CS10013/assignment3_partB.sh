sudo ip netns add h1
sudo ip netns add h2
sudo ip netns add h3
sudo ip netns add R

sudo ip netns exec R ip link add name myb type bridge
sudo ip link add veth1 type veth peer name veth2
sudo ip link add veth6 type veth peer name veth3
sudo ip link add veth5 type veth peer name veth4

sudo ip link set veth1 netns h1
sudo ip link set veth6 netns h2
sudo ip link set veth5 netns h3
sudo ip link set veth2 netns R
sudo ip link set veth3 netns R
sudo ip link set veth4 netns R

sudo ip -n R link set myb up

sudo ip -n h1 addr add 10.0.10.13/24 dev veth1
sudo ip -n h2 addr add 10.0.20.13/24 dev veth6
sudo ip -n h3 addr add 10.0.30.13/24 dev veth5
sudo ip -n h1 link set dev veth1 up
sudo ip -n h2 link set dev veth6 up
sudo ip -n h3 link set dev veth5 up

sudo ip netns exec R ip link set veth2 master myb
sudo ip netns exec R ip link set veth3 master myb
sudo ip netns exec R ip link set veth4 master myb

sudo ip -n R addr add 10.0.10.1/24 dev veth2
sudo ip -n R addr add 10.0.20.1/24 dev veth3
sudo ip -n R addr add 10.0.30.1/24 dev veth4
sudo ip -n R link set veth2 up
sudo ip -n R link set veth3 up
sudo ip -n R link set veth4 up

sudo ip -n h1 route add default via 10.0.10.13
sudo ip -n h2 route add default via 10.0.20.13
sudo ip -n h3 route add default via 10.0.30.13

sudo sysctl -w net.ipv4.ip_forward=1

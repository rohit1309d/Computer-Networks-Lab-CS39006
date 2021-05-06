sudo ip netns add namespace1
sudo ip netns add namespace2

sudo ip link add veth0 type veth peer name veth1

sudo ip link set veth0 netns namespace1
sudo ip link set veth1 netns namespace2

sudo ip netns exec namespace1 ip addr add 10.1.1.0/24 dev veth0
sudo ip netns exec namespace2 ip addr add 10.1.2.0/24 dev veth1
sudo ip netns exec namespace1 ip link set dev veth0 up
sudo ip netns exec namespace2 ip link set dev veth1 up

sudo ip -n namespace1 route add 10.1.2.0/24 dev veth0
sudo ip -n namespace2 route add 10.1.1.0/24 dev veth1

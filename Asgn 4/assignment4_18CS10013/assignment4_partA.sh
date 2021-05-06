# run "sudo -s" before executing this file

sysctl -w net.ipv4.ip_forward=1

ip netns add N1
ip netns add N2
ip netns add N3
ip netns add N4

ip link add V1 type veth peer name V2
ip link add V3 type veth peer name V4
ip link add V5 type veth peer name V6

ip link set V1 netns N1
ip link set V2 netns N2
ip link set V3 netns N2
ip link set V4 netns N3
ip link set V5 netns N3
ip link set V6 netns N4


ip -n N1 addr add 10.0.10.13/24 dev V1
ip -n N1 link set dev V1 up

ip -n N2 addr add 10.0.10.14/24 dev V2
ip -n N2 link set dev V2 up

ip -n N2 addr add 10.0.20.13/24 dev V3
ip -n N2 link set dev V3 up

ip -n N3 addr add 10.0.20.14/24 dev V4
ip -n N3 link set dev V4 up

ip -n N3 addr add 10.0.30.13/24 dev V5
ip -n N3 link set dev V5 up

ip -n N4 addr add 10.0.30.14/24 dev V6
ip -n N4 link set dev V6 up

ip netns exec N1 ip link set dev lo up
ip netns exec N2 ip link set dev lo up
ip netns exec N3 ip link set dev lo up
ip netns exec N4 ip link set dev lo up

ip netns exec N1 ip route add 10.0.20.0/24 via 10.0.10.14 dev V1
ip netns exec N3 ip route add 10.0.10.0/24 via 10.0.20.13 dev V4
ip netns exec N1 ip route add 10.0.30.0/24 via 10.0.10.14 dev V1
ip netns exec N4 ip route add 10.0.10.0/24 via 10.0.30.13 dev V6
ip netns exec N2 ip route add 10.0.30.0/24 via 10.0.20.14 dev V3
ip netns exec N4 ip route add 10.0.20.0/24 via 10.0.30.13 dev V6

for((i=1;i<=4;i+=1)); 
do 
ip netns exec N$i ping -c3 10.0.10.13;
ip netns exec N$i ping -c3 10.0.10.14;
ip netns exec N$i ping -c3 10.0.20.13;
ip netns exec N$i ping -c3 10.0.20.14;
ip netns exec N$i ping -c3 10.0.30.13;
ip netns exec N$i ping -c3 10.0.30.14;
done
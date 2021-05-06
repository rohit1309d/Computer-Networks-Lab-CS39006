# run "sudo -s" before executing this file

sysctl -w net.ipv4.ip_forward=1

ip netns add N1
ip netns add N2
ip netns add N3
ip netns add N4
ip netns add N5
ip netns add N6

ip link add V1 type veth peer name V2
ip link add V3 type veth peer name V4
ip link add V5 type veth peer name V6
ip link add V7 type veth peer name V8
ip link add V9 type veth peer name V10
ip link add V11 type veth peer name V12

ip link set V1 netns N1
ip link set V2 netns N2
ip link set V3 netns N2
ip link set V4 netns N3
ip link set V5 netns N3
ip link set V6 netns N4
ip link set V7 netns N4
ip link set V8 netns N5
ip link set V9 netns N5
ip link set V10 netns N6
ip link set V11 netns N6
ip link set V12 netns N1

ip -n N1 addr add 10.0.10.13/24 dev V1
ip -n N2 addr add 10.0.10.14/24 dev V2
ip -n N2 addr add 10.0.20.13/24 dev V3
ip -n N3 addr add 10.0.20.14/24 dev V4
ip -n N3 addr add 10.0.30.13/24 dev V5
ip -n N4 addr add 10.0.30.14/24 dev V6
ip -n N4 addr add 10.0.40.13/24 dev V7
ip -n N5 addr add 10.0.40.14/24 dev V8
ip -n N5 addr add 10.0.50.13/24 dev V9
ip -n N6 addr add 10.0.50.14/24 dev V10
ip -n N6 addr add 10.0.60.13/24 dev V11
ip -n N1 addr add 10.0.60.14/24 dev V12

ip -n N1 link set dev V1 up
ip -n N2 link set dev V2 up
ip -n N2 link set dev V3 up
ip -n N3 link set dev V4 up
ip -n N3 link set dev V5 up
ip -n N4 link set dev V6 up
ip -n N4 link set dev V7 up
ip -n N5 link set dev V8 up
ip -n N5 link set dev V9 up
ip -n N6 link set dev V10 up
ip -n N6 link set dev V11 up
ip -n N1 link set dev V12 up

ip netns exec N1 ip link set dev lo up
ip netns exec N2 ip link set dev lo up
ip netns exec N3 ip link set dev lo up
ip netns exec N4 ip link set dev lo up
ip netns exec N5 ip link set dev lo up
ip netns exec N6 ip link set dev lo up

# N1
ip netns exec N1 ip route add 10.0.20.0/24 via 10.0.10.14 dev V1
ip netns exec N1 ip route add 10.0.30.0/24 via 10.0.10.14 dev V1
ip netns exec N1 ip route add 10.0.40.0/24 via 10.0.10.14 dev V1
ip netns exec N1 ip route add 10.0.50.0/24 via 10.0.10.14 dev V1

# N2
ip netns exec N2 ip route add 10.0.30.0/24 via 10.0.20.14 dev V3
ip netns exec N2 ip route add 10.0.40.0/24 via 10.0.20.14 dev V3
ip netns exec N2 ip route add 10.0.50.0/24 via 10.0.20.14 dev V3
ip netns exec N2 ip route add 10.0.60.0/24 via 10.0.20.14 dev V3

# N3
ip netns exec N3 ip route add 10.0.40.0/24 via 10.0.30.14 dev V5
ip netns exec N3 ip route add 10.0.50.0/24 via 10.0.30.14 dev V5
ip netns exec N3 ip route add 10.0.60.0/24 via 10.0.30.14 dev V5
ip netns exec N3 ip route add 10.0.10.0/24 via 10.0.30.14 dev V5

# N4
ip netns exec N4 ip route add 10.0.50.0/24 via 10.0.40.14 dev V7
ip netns exec N4 ip route add 10.0.60.0/24 via 10.0.40.14 dev V7
ip netns exec N4 ip route add 10.0.10.0/24 via 10.0.40.14 dev V7
ip netns exec N4 ip route add 10.0.20.0/24 via 10.0.40.14 dev V7

# N5
ip netns exec N5 ip route add 10.0.60.0/24 via 10.0.50.14 dev V9
ip netns exec N5 ip route add 10.0.10.0/24 via 10.0.50.14 dev V9
ip netns exec N5 ip route add 10.0.20.0/24 via 10.0.50.14 dev V9
ip netns exec N5 ip route add 10.0.30.0/24 via 10.0.50.14 dev V9

# N6
ip netns exec N6 ip route add 10.0.10.0/24 via 10.0.60.14 dev V11
ip netns exec N6 ip route add 10.0.20.0/24 via 10.0.60.14 dev V11
ip netns exec N6 ip route add 10.0.30.0/24 via 10.0.60.14 dev V11
ip netns exec N6 ip route add 10.0.40.0/24 via 10.0.60.14 dev V11

ip netns exec N1 traceroute 10.0.40.14
sleep 2
ip netns exec N3 traceroute 10.0.40.14
sleep 2
ip netns exec N3 traceroute 10.0.10.13
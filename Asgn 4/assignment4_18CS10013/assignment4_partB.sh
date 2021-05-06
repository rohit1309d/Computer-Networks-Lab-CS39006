# run "sudo -s" before executing this file

sysctl -w net.ipv4.ip_forward=1

ip netns add H1
ip netns add H2
ip netns add H3
ip netns add H4

ip netns add R1
ip netns add R2
ip netns add R3

ip link add V1 type veth peer name V2
ip link add V3 type veth peer name V4
ip link add V5 type veth peer name V6
ip link add V7 type veth peer name V8
ip link add V9 type veth peer name V10
ip link add V11 type veth peer name V12

ip link set V1 netns H1
ip link set V2 netns R1
ip link set V3 netns H2
ip link set V4 netns R1
ip link set V5 netns R1
ip link set V6 netns R2
ip link set V7 netns R2
ip link set V8 netns R3
ip link set V9 netns R3
ip link set V10 netns H3
ip link set V11 netns R3
ip link set V12 netns H4

ip -n H1 addr add 10.0.10.13/24 dev V1
ip -n R1 addr add 10.0.10.14/24 dev V2
ip -n H2 addr add 10.0.20.13/24 dev V3
ip -n R1 addr add 10.0.20.14/24 dev V4
ip -n R1 addr add 10.0.30.13/24 dev V5
ip -n R2 addr add 10.0.30.14/24 dev V6
ip -n R2 addr add 10.0.40.13/24 dev V7
ip -n R3 addr add 10.0.40.14/24 dev V8
ip -n R3 addr add 10.0.50.13/24 dev V9
ip -n H3 addr add 10.0.50.14/24 dev V10
ip -n R3 addr add 10.0.60.13/24 dev V11
ip -n H4 addr add 10.0.60.14/24 dev V12

ip -n H1 link set dev V1 up
ip -n R1 link set dev V2 up
ip -n H2 link set dev V3 up
ip -n R1 link set dev V4 up
ip -n R1 link set dev V5 up
ip -n R2 link set dev V6 up
ip -n R2 link set dev V7 up
ip -n R3 link set dev V8 up
ip -n R3 link set dev V9 up
ip -n H3 link set dev V10 up
ip -n R3 link set dev V11 up
ip -n H4 link set dev V12 up

ip netns exec H1 ip link set dev lo up
ip netns exec H2 ip link set dev lo up
ip netns exec H3 ip link set dev lo up
ip netns exec H4 ip link set dev lo up

ip netns exec R1 ip link set dev lo up
ip netns exec R2 ip link set dev lo up
ip netns exec R3 ip link set dev lo up

# H1
ip netns exec H1 ip route add 10.0.20.0/24 via 10.0.10.14 dev V1
ip netns exec H1 ip route add 10.0.30.0/24 via 10.0.10.14 dev V1
ip netns exec H1 ip route add 10.0.40.0/24 via 10.0.10.14 dev V1
ip netns exec H1 ip route add 10.0.50.0/24 via 10.0.10.14 dev V1
ip netns exec H1 ip route add 10.0.60.0/24 via 10.0.10.14 dev V1

# H2
ip netns exec H2 ip route add 10.0.10.0/24 via 10.0.20.14 dev V3
ip netns exec H2 ip route add 10.0.30.0/24 via 10.0.20.14 dev V3
ip netns exec H2 ip route add 10.0.40.0/24 via 10.0.20.14 dev V3
ip netns exec H2 ip route add 10.0.50.0/24 via 10.0.20.14 dev V3
ip netns exec H2 ip route add 10.0.60.0/24 via 10.0.20.14 dev V3

# H3
ip netns exec H3 ip route add 10.0.10.0/24 via 10.0.50.13 dev V10
ip netns exec H3 ip route add 10.0.20.0/24 via 10.0.50.13 dev V10
ip netns exec H3 ip route add 10.0.30.0/24 via 10.0.50.13 dev V10
ip netns exec H3 ip route add 10.0.40.0/24 via 10.0.50.13 dev V10
ip netns exec H3 ip route add 10.0.60.0/24 via 10.0.50.13 dev V10

# H4
ip netns exec H4 ip route add 10.0.10.0/24 via 10.0.60.13 dev V12
ip netns exec H4 ip route add 10.0.20.0/24 via 10.0.60.13 dev V12
ip netns exec H4 ip route add 10.0.30.0/24 via 10.0.60.13 dev V12
ip netns exec H4 ip route add 10.0.40.0/24 via 10.0.60.13 dev V12
ip netns exec H4 ip route add 10.0.50.0/24 via 10.0.60.13 dev V12

# R1
ip netns exec R1 ip route add 10.0.40.0/24 via 10.0.30.14 dev V5
ip netns exec R1 ip route add 10.0.50.0/24 via 10.0.30.14 dev V5
ip netns exec R1 ip route add 10.0.60.0/24 via 10.0.30.14 dev V5

# R3
ip netns exec R3 ip route add 10.0.10.0/24 via 10.0.40.13 dev V8
ip netns exec R3 ip route add 10.0.20.0/24 via 10.0.40.13 dev V8
ip netns exec R3 ip route add 10.0.30.0/24 via 10.0.40.13 dev V8

# R2
ip netns exec R2 ip route add 10.0.10.0/24 via 10.0.30.13 dev V6
ip netns exec R2 ip route add 10.0.20.0/24 via 10.0.30.13 dev V6
ip netns exec R2 ip route add 10.0.50.0/24 via 10.0.40.14 dev V7
ip netns exec R2 ip route add 10.0.60.0/24 via 10.0.40.14 dev V7


for((i=1;i<=4;i+=1)); 
do 
sudo ip netns exec H$i ping -c3 10.0.10.13;
sudo ip netns exec H$i ping -c3 10.0.10.14;
sudo ip netns exec H$i ping -c3 10.0.20.13;
sudo ip netns exec H$i ping -c3 10.0.20.14;
sudo ip netns exec H$i ping -c3 10.0.30.13;
sudo ip netns exec H$i ping -c3 10.0.30.14;
sudo ip netns exec H$i ping -c3 10.0.40.13;
sudo ip netns exec H$i ping -c3 10.0.40.14;
sudo ip netns exec H$i ping -c3 10.0.50.13;
sudo ip netns exec H$i ping -c3 10.0.50.14;
sudo ip netns exec H$i ping -c3 10.0.60.13;
sudo ip netns exec H$i ping -c3 10.0.60.14;
done

for((i=1;i<=3;i+=1)); 
do 
sudo ip netns exec R$i ping -c3 10.0.10.13;
sudo ip netns exec R$i ping -c3 10.0.10.14;
sudo ip netns exec R$i ping -c3 10.0.20.13;
sudo ip netns exec R$i ping -c3 10.0.20.14;
sudo ip netns exec R$i ping -c3 10.0.30.13;
sudo ip netns exec R$i ping -c3 10.0.30.14;
sudo ip netns exec R$i ping -c3 10.0.40.13;
sudo ip netns exec R$i ping -c3 10.0.40.14;
sudo ip netns exec R$i ping -c3 10.0.50.13;
sudo ip netns exec R$i ping -c3 10.0.50.14;
sudo ip netns exec R$i ping -c3 10.0.60.13;
sudo ip netns exec R$i ping -c3 10.0.60.14;
done


ip netns exec H1 traceroute 10.0.60.14
sleep 1
ip netns exec H3 traceroute 10.0.60.14
sleep 1
ip netns exec H4 traceroute 10.0.20.13


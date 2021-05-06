sysctl -w net.ipv4.ip_forward=1

# creating given namespaces
ip netns add H1
ip netns add H2
ip netns add H3
ip netns add H4
ip netns add R1
ip netns add R2
ip netns add R3
ip netns add R4
ip netns add R5
ip netns add R6

# creating interfaces
ip link add v1 type veth peer name v2
ip link add v3 type veth peer name v4
ip link add v5 type veth peer name v6
ip link add v7 type veth peer name v8
ip link add v9 type veth peer name v10
ip link add v11 type veth peer name v12
ip link add v13 type veth peer name v14
ip link add v15 type veth peer name v16
ip link add v17 type veth peer name v18

# Linking interfaces to namespaces
ip link set v1 netns H1
ip link set v2 netns R1
ip link set v3 netns R1
ip link set v4 netns R2
ip link set v5 netns R2
ip link set v6 netns R3
ip link set v7 netns R3
ip link set v8 netns H2
ip link set v9 netns R2
ip link set v10 netns R4
ip link set v11 netns R4
ip link set v12 netns R5
ip link set v13 netns R5
ip link set v14 netns H3
ip link set v15 netns R4
ip link set v16 netns R6
ip link set v17 netns R6
ip link set v18 netns H4

# Assigning ip addresses to namespaces
ip -n H1 addr add 10.10.10.13/24 dev v1
ip -n R1 addr add 10.10.10.14/24 dev v2
ip -n R1 addr add 10.10.20.13/24 dev v3
ip -n R2 addr add 10.10.20.14/24 dev v4
ip -n R2 addr add 10.10.30.13/24 dev v5
ip -n R3 addr add 10.10.30.14/24 dev v6
ip -n R3 addr add 10.10.40.13/24 dev v7
ip -n H2 addr add 10.10.40.14/24 dev v8
ip -n R2 addr add 10.10.50.13/24 dev v9
ip -n R4 addr add 10.10.50.14/24 dev v10
ip -n R4 addr add 10.20.10.13/24 dev v11
ip -n R5 addr add 10.20.10.14/24 dev v12
ip -n R5 addr add 10.20.20.13/24 dev v13
ip -n H3 addr add 10.20.20.14/24 dev v14
ip -n R4 addr add 10.30.10.13/24 dev v15
ip -n R6 addr add 10.30.10.14/24 dev v16
ip -n R6 addr add 10.30.20.13/24 dev v17
ip -n H4 addr add 10.30.20.14/24 dev v18

# Activating interfaces
ip -n H1 link set dev v1 up
ip -n R1 link set dev v2 up
ip -n R1 link set dev v3 up
ip -n R2 link set dev v4 up
ip -n R2 link set dev v5 up
ip -n R3 link set dev v6 up
ip -n R3 link set dev v7 up
ip -n H2 link set dev v8 up
ip -n R2 link set dev v9 up
ip -n R4 link set dev v10 up
ip -n R4 link set dev v11 up
ip -n R5 link set dev v12 up
ip -n R5 link set dev v13 up
ip -n H3 link set dev v14 up
ip -n R4 link set dev v15 up
ip -n R6 link set dev v16 up
ip -n R6 link set dev v17 up
ip -n H4 link set dev v18 up

# Loopback interfaces enabling
ip netns exec H1 ip link set dev lo up
ip netns exec H2 ip link set dev lo up
ip netns exec H3 ip link set dev lo up
ip netns exec H4 ip link set dev lo up
ip netns exec R1 ip link set dev lo up
ip netns exec R2 ip link set dev lo up
ip netns exec R3 ip link set dev lo up
ip netns exec R4 ip link set dev lo up
ip netns exec R5 ip link set dev lo up
ip netns exec R6 ip link set dev lo up

# Adding routes to corresponding Namespaces

# Connecting H1 from v1 via v2 to the following pairs
# (v3,v4) (v5,v6) (v7,v8) (v9,v10) (v11,v12) (v13,v14) (v15,v16) (v17,v18)
ip netns exec H1 ip route add 10.10.20.0/24 via 10.10.10.14 dev v1
ip netns exec H1 ip route add 10.10.30.0/24 via 10.10.10.14 dev v1
ip netns exec H1 ip route add 10.10.40.0/24 via 10.10.10.14 dev v1
ip netns exec H1 ip route add 10.10.50.0/24 via 10.10.10.14 dev v1
ip netns exec H1 ip route add 10.20.10.0/24 via 10.10.10.14 dev v1
ip netns exec H1 ip route add 10.20.20.0/24 via 10.10.10.14 dev v1
ip netns exec H1 ip route add 10.30.10.0/24 via 10.10.10.14 dev v1
ip netns exec H1 ip route add 10.30.20.0/24 via 10.10.10.14 dev v1

# Connecting H2 from v8 via v7 to the following pairs
# (v1,v2) (v3,v4) (v5,v6) (v9,v10) (v11,v12) (v13,v14) (v15,v16) (v17,v18)
ip netns exec H2 ip route add 10.10.10.0/24 via 10.10.40.13 dev v8
ip netns exec H2 ip route add 10.10.20.0/24 via 10.10.40.13 dev v8
ip netns exec H2 ip route add 10.10.30.0/24 via 10.10.40.13 dev v8
ip netns exec H2 ip route add 10.10.50.0/24 via 10.10.40.13 dev v8
ip netns exec H2 ip route add 10.20.10.0/24 via 10.10.40.13 dev v8
ip netns exec H2 ip route add 10.20.20.0/24 via 10.10.40.13 dev v8
ip netns exec H2 ip route add 10.30.10.0/24 via 10.10.40.13 dev v8
ip netns exec H2 ip route add 10.30.20.0/24 via 10.10.40.13 dev v8

# Connecting H3 from v14 via v13 to the following pairs
# (v1,v2) (v3,v4) (v5,v6) (v7,v8) (v9,v10) (v11,v12) (v15,v16) (v17,v18)
ip netns exec H3 ip route add 10.10.10.0/24 via 10.20.20.13 dev v14
ip netns exec H3 ip route add 10.10.20.0/24 via 10.20.20.13 dev v14
ip netns exec H3 ip route add 10.10.30.0/24 via 10.20.20.13 dev v14
ip netns exec H3 ip route add 10.10.40.0/24 via 10.20.20.13 dev v14
ip netns exec H3 ip route add 10.10.50.0/24 via 10.20.20.13 dev v14
ip netns exec H3 ip route add 10.20.10.0/24 via 10.20.20.13 dev v14
ip netns exec H3 ip route add 10.30.10.0/24 via 10.20.20.13 dev v14
ip netns exec H3 ip route add 10.30.20.0/24 via 10.20.20.13 dev v14

# Connecting H4 from v18 via v17 to the following pairs
# (v1,v2) (v3,v4) (v5,v6) (v7,v8) (v9,v10) (v11,v12) (v13,v14) (v15,v16) 
ip netns exec H4 ip route add 10.10.10.0/24 via 10.30.20.13 dev v18
ip netns exec H4 ip route add 10.10.20.0/24 via 10.30.20.13 dev v18
ip netns exec H4 ip route add 10.10.30.0/24 via 10.30.20.13 dev v18
ip netns exec H4 ip route add 10.10.40.0/24 via 10.30.20.13 dev v18
ip netns exec H4 ip route add 10.10.50.0/24 via 10.30.20.13 dev v18
ip netns exec H4 ip route add 10.20.10.0/24 via 10.30.20.13 dev v18
ip netns exec H4 ip route add 10.20.20.0/24 via 10.30.20.13 dev v18
ip netns exec H4 ip route add 10.30.10.0/24 via 10.30.20.13 dev v18

# Connecting R1 from v3 via v4 to the following pairs
# (v5,v6) (v7,v8) (v9,v10) (v11,v12) (v13,v14) (v15,v16) (v17,v18)
ip netns exec R1 ip route add 10.10.30.0/24 via 10.10.20.14 dev v3
ip netns exec R1 ip route add 10.10.40.0/24 via 10.10.20.14 dev v3
ip netns exec R1 ip route add 10.10.50.0/24 via 10.10.20.14 dev v3
ip netns exec R1 ip route add 10.20.10.0/24 via 10.10.20.14 dev v3
ip netns exec R1 ip route add 10.20.20.0/24 via 10.10.20.14 dev v3
ip netns exec R1 ip route add 10.30.10.0/24 via 10.10.20.14 dev v3
ip netns exec R1 ip route add 10.30.20.0/24 via 10.10.20.14 dev v3

# Connecting R3 from v6 via v5 to the following pairs
# (v1,v2) (v3,v4) (v9,v10) (v11,v12) (v13,v14) (v15,v16) (v17,v18)
ip netns exec R3 ip route add 10.10.10.0/24 via 10.10.30.13 dev v6
ip netns exec R3 ip route add 10.10.20.0/24 via 10.10.30.13 dev v6
ip netns exec R3 ip route add 10.10.50.0/24 via 10.10.30.13 dev v6
ip netns exec R3 ip route add 10.20.10.0/24 via 10.10.30.13 dev v6
ip netns exec R3 ip route add 10.20.20.0/24 via 10.10.30.13 dev v6
ip netns exec R3 ip route add 10.30.10.0/24 via 10.10.30.13 dev v6
ip netns exec R3 ip route add 10.30.20.0/24 via 10.10.30.13 dev v6

# Connecting R5 from v12 via v11 to the following pairs
# (v1,v2) (v3,v4) (v5,v6) (v7,v8) (v9,v10) (v15,v16) (v17,v18)
ip netns exec R5 ip route add 10.10.10.0/24 via 10.20.10.13 dev v12
ip netns exec R5 ip route add 10.10.20.0/24 via 10.20.10.13 dev v12
ip netns exec R5 ip route add 10.10.30.0/24 via 10.20.10.13 dev v12
ip netns exec R5 ip route add 10.10.40.0/24 via 10.20.10.13 dev v12
ip netns exec R5 ip route add 10.10.50.0/24 via 10.20.10.13 dev v12
ip netns exec R5 ip route add 10.30.10.0/24 via 10.20.10.13 dev v12
ip netns exec R5 ip route add 10.30.20.0/24 via 10.20.10.13 dev v12

# Connecting R6 from v16 via v15 to the following pairs
# (v1,v2) (v3,v4) (v5,v6) (v7,v8) (v9,v10) (v11,v12) (v13,v14)  
ip netns exec R6 ip route add 10.10.10.0/24 via 10.30.10.13 dev v16
ip netns exec R6 ip route add 10.10.20.0/24 via 10.30.10.13 dev v16
ip netns exec R6 ip route add 10.10.30.0/24 via 10.30.10.13 dev v16
ip netns exec R6 ip route add 10.10.40.0/24 via 10.30.10.13 dev v16
ip netns exec R6 ip route add 10.10.50.0/24 via 10.30.10.13 dev v16
ip netns exec R6 ip route add 10.20.10.0/24 via 10.30.10.13 dev v16
ip netns exec R6 ip route add 10.20.20.0/24 via 10.30.10.13 dev v16

# Connecting R2 from v4 via v3 to the following pairs
# (v1,v2) (v7,v8) (v11,v12) (v13,v14) (v15,v16) (v17,v18)
ip netns exec R2 ip route add 10.10.10.0/24 via 10.10.20.13 dev v4
ip netns exec R2 ip route add 10.10.40.0/24 via 10.10.30.14 dev v5
ip netns exec R2 ip route add 10.20.10.0/24 via 10.10.50.14 dev v9
ip netns exec R2 ip route add 10.20.20.0/24 via 10.10.50.14 dev v9
ip netns exec R2 ip route add 10.30.10.0/24 via 10.10.50.14 dev v9
ip netns exec R2 ip route add 10.30.20.0/24 via 10.10.50.14 dev v9

# Connecting R4 from v9 via v10 to the following pairs
# (v1,v2) (v3,v4) (v5,v6) (v7,v8) (v13,v14) (v17,v18)
ip netns exec R4 ip route add 10.10.10.0/24 via 10.10.50.13 dev v10
ip netns exec R4 ip route add 10.10.20.0/24 via 10.10.50.13 dev v10
ip netns exec R4 ip route add 10.10.30.0/24 via 10.10.50.13 dev v10
ip netns exec R4 ip route add 10.10.40.0/24 via 10.10.50.13 dev v10
ip netns exec R4 ip route add 10.20.20.0/24 via 10.20.10.14 dev v11
ip netns exec R4 ip route add 10.30.20.0/24 via 10.30.10.14 dev v15

ip netns exec H1 traceroute 10.30.20.14
sleep 1
ip netns exec H3 traceroute 10.10.40.14
sleep 1
ip netns exec H4 traceroute 10.20.20.14

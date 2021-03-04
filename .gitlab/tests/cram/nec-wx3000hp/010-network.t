Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Check correct routing table:

  $ R ip route
  default via 10.0.0.1 dev eth1  src 10.0.0.2 
  10.0.0.0/24 dev eth1 scope link  src 10.0.0.2 
  192.168.1.0/24 dev br-lan scope link  src 192.168.1.1 

Check correct interface setup:

  $ R "ip link | grep ^\\\\d | cut -d: -f2-" | LC_ALL=C sort
   br-lan: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP qlen 1000
   eth0_0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
   eth0_1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast master br-lan state DOWN qlen 1000
   eth0_2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast master br-lan state DOWN qlen 1000
   eth0_3: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast master br-lan state DOWN qlen 1000
   eth0_4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master br-lan state UP qlen 1000
   eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN qlen 1000
   lite0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN qlen 1000
   lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1
   loopdev0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
   rtlog0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000

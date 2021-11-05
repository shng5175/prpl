Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Check that ubus has all expected services available:

  $ R "ubus list | grep -v '^[[:upper:]]'"
  bbfd
  bbfd.raw
  dhcp
  dnsmasq
  file
  iwinfo
  luci
  luci-rpc
  network
  network.device
  network.interface
  network.interface.guest
  network.interface.lan
  network.interface.loopback
  network.interface.wan
  network.interface.wan6
  network.wireless
  prplmesh
  rpc-sys
  service
  session
  system
  topology
  uci
  umdns

Check that ubus has expected datamodels available:

  $ R "ubus list | grep '[[:upper:]]' | grep -v '\.[[:digit:]]'"
  ACLManager
  ACLManager.Role
  Bridging
  Bridging.Bridge
  DHCPv4
  DHCPv4.Server
  DHCPv4.Server.Pool
  DHCPv4c
  DHCPv4c.Client
  DHCPv6
  DHCPv6.Client
  DHCPv6.Server
  DHCPv6.Server.Pool
  Device
  Device.InterfaceStack
  DeviceInfo
  DeviceInfo.DeviceImageFile
  DeviceInfo.FirmwareImage
  DeviceInfo.Location
  DeviceInfo.MemoryStatus
  DeviceInfo.Processor
  DeviceInfo.VendorConfigFile
  DeviceInfo.VendorLogFile
  Ethernet
  Ethernet.Interface
  Ethernet.Link
  Ethernet.VLANTermination
  Firewall
  Firewall.Chain
  Firewall.Level
  Firewall.X_Prpl_DMZ
  Firewall.X_Prpl_Pinhole
  Firewall.X_Prpl_Policy
  Firewall.X_Prpl_PortTrigger
  Firewall.X_Prpl_Service
  IP
  IP.ActivePort
  IP.Interface
  NAT
  NAT.InterfaceSetting
  NAT.PortMapping
  NetDev
  NetDev.ConversionTable
  NetDev.ConversionTable.Protocol
  NetDev.ConversionTable.Scope
  NetDev.ConversionTable.Table
  NetDev.Link
  NetModel
  NetModel.Intf
  Routing
  Routing.RIP
  Routing.RIP.InterfaceSetting
  Routing.RouteInformation
  Routing.RouteInformation.InterfaceSetting
  Routing.Router
  Time
  Time.X_PRPL_TimeServer
  Time.X_PRPL_TimeServer.Intf
  Users
  Users.Group
  Users.Role
  Users.SupportedShell
  Users.User
  X_PRPL_WANManager
  X_PRPL_WANManager.WAN
  X_Prpl_PersistentConfiguration
  X_Prpl_PersistentConfiguration.Config
  X_Prpl_PersistentConfiguration.Config.Security
  X_Prpl_PersistentConfiguration.Service

Check that we've correct bridge aliases:

  $ R "ubus call Bridging _get \"{'rel_path':'Bridge.*.Alias'}\" | jsonfilter -e @[*].Alias | sort"
  guest
  lan

Check that we've correct DHCP pool settings:

  $ R "ubus call DHCPv4.Server.Pool _get \"{'rel_path':'*'}\" | grep -E '(Alias|MinAddres|MaxAddress|Enable|Servers|Status)' | sort"
  \t\t"Alias": "guest", (esc)
  \t\t"Alias": "lan", (esc)
  \t\t"DNSServers": "192.168.1.1", (esc)
  \t\t"DNSServers": "192.168.2.1", (esc)
  \t\t"Enable": false, (esc)
  \t\t"Enable": true, (esc)
  \t\t"MaxAddress": "192.168.1.249", (esc)
  \t\t"MaxAddress": "192.168.2.249", (esc)
  \t\t"MinAddress": "192.168.1.100", (esc)
  \t\t"MinAddress": "192.168.2.100", (esc)
  \t\t"Status": "Enabled", (esc)
  \t\t"Status": "Error_Misconfigured", (esc)

  $ R "ubus call DHCPv6.Server.Pool _get \"{'rel_path':'*'}\" | grep -E '(Alias|Enable|Status)' | sort"
  \t\t"Alias": "guest", (esc)
  \t\t"Alias": "lan", (esc)
  \t\t"Enable": false, (esc)
  \t\t"Enable": true, (esc)
  \t\t"IANAEnable": false, (esc)
  \t\t"IANAEnable": false, (esc)
  \t\t"IAPDEnable": false, (esc)
  \t\t"IAPDEnable": false, (esc)
  \t\t"Status": "Disabled", (esc)
  \t\t"Status": "Enabled", (esc)

Check that we've expected firewall rules:
  $ R "ubus call Firewall _get \"{'rel_path':'X_Prpl_Service.'}\" | jsonfilter -e @[*].Alias -e @[*].Protocol -e @[*].DestinationPort | grep -v '^$' | sort"
  123
  17
  22
  53
  546
  547
  6,17
  67
  68
  80,443
  80,443
  ICMP
  IGMP
  IGMP
  TCP
  TCP
  TCP
  UDP
  UDP
  UDP
  UDP,TCP
  cpe-Time-br-lan
  cpe-dhcpv4c-wan
  dhcp-server
  dhcpv6-client
  dhcpv6-server
  dns
  http
  http-guest
  icmp-8
  igmp-lan
  igmp-wan
  ssh

  $ R "ubus call Firewall.Chain _get \"{'rel_path':'*.Rule.*'}\" | jsonfilter -e @[*].Alias -e @[*].Protocol -e @[*].DestPort | sort"
  -1
  -1
  -1
  -1
  -1
  -1
  -1
  -1
  1
  110
  123
  143
  17
  17
  20
  21
  22
  25
  443
  53
  53
  6
  6
  6
  6
  6
  6
  6
  6
  6
  6
  80
  cpe-Rule-1
  cstate
  dns-tcp
  dns-udp
  ftp
  ftp-data
  http
  https
  icmp
  imap
  last-rule
  last-tcp-rule
  ntp
  pop3
  smtp
  ssh

Check that we've correct hostname and release info:

  $ R "ubus -S call system board | jsonfilter -e '@.hostname' -e '@.release.distribution'"
  prplOS
  OpenWrt

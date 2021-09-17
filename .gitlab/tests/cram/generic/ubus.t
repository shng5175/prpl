Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Check that ubus has all expected services available:

  $ R ubus list | grep -v dhcp_event
  DHCPv6
  DHCPv6.Server
  DHCPv6.Server.Pool
  DHCPv6.Server.Pool.1
  DHCPv6.Server.Pool.1.Client
  DHCPv6.Server.Pool.1.Client.IPv6Address
  DHCPv6.Server.Pool.1.Client.IPv6Prefix
  DHCPv6.Server.Pool.1.Client.Option
  DHCPv6.Server.Pool.1.Option
  DHCPv6.Server.Pool.2
  DHCPv6.Server.Pool.2.Client
  DHCPv6.Server.Pool.2.Client.IPv6Address
  DHCPv6.Server.Pool.2.Client.IPv6Prefix
  DHCPv6.Server.Pool.2.Client.Option
  DHCPv6.Server.Pool.2.Option
  DeviceInfo
  DeviceInfo.DeviceImageFile
  DeviceInfo.FirmwareImage
  DeviceInfo.Location
  DeviceInfo.MemoryStatus
  DeviceInfo.Processor
  DeviceInfo.VendorConfigFile
  DeviceInfo.VendorLogFile
  Firewall
  Firewall.Chain
  Firewall.Chain.1
  Firewall.Chain.1.Rule
  Firewall.Level
  Firewall.X_Prpl_DMZ
  Firewall.X_Prpl_Pinhole
  Firewall.X_Prpl_Policy
  Firewall.X_Prpl_Policy.1
  Firewall.X_Prpl_PortTrigger
  Firewall.X_Prpl_Service
  NAT
  NAT.InterfaceSetting
  NAT.PortMapping
  NetModel
  NetModel.Intf
  bbfd
  bbfd.raw
  dhcp
  dnsmasq
  file
  iwinfo
  log
  luci
  luci-rpc
  network
  network.device
  network.interface
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

Check that we've correct hostname and release info:

  $ R "ubus -S call system board | jsonfilter -e '@.hostname' -e '@.release.distribution'"
  prplOS
  OpenWrt

Check that log service is running:

  $ R "ubus -S call service list | jsonfilter -e '@.log.instances.instance1.running'"
  true

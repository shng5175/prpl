Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Check that ubus has all expected services available:

  $ R ubus list | grep -v dhcp_event
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
  prplWrt
  OpenWrt

Check that log service is running:

  $ R "ubus -S call service list | jsonfilter -e '@.log.instances.instance1.running'"
  true

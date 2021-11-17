Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Check that we've correct system info:

  $ R "ubus call system board | jsonfilter -e @.system -e @.model -e @.board_name"
  ARMv7 Processor rev 5 (v7l)
  GL.iNet GL-B1300
  glinet,gl-b1300

  $ R "ubus call DeviceInfo _get | jsonfilter -e '@[\"DeviceInfo.\"].ProductClass'"
  GL.iNet GL-B1300

Check that we've correct bridge port aliases:

  $ R "ubus call Bridging _get \"{'rel_path':'Bridge.*.Port.*.Alias'}\" | jsonfilter -e @[*].Alias | sort"
  ETH0
  GUEST
  bridge
  default_wlan0
  default_wlan1
  guest_wlan0
  guest_wlan1

Check that we've correct ethernet interface details:

  $ R "ubus call Ethernet _get \"{'rel_path':'Interface.'}\" | grep -E '(Alias|Enable|Name)' | sort"
  \t\t"Alias": "ETH0", (esc)
  \t\t"Alias": "ETH1", (esc)
  \t\t"Alias": "ETH2", (esc)
  \t\t"Alias": "ETH3", (esc)
  \t\t"EEEEnable": false, (esc)
  \t\t"EEEEnable": false, (esc)
  \t\t"EEEEnable": false, (esc)
  \t\t"EEEEnable": false, (esc)
  \t\t"Enable": true, (esc)
  \t\t"Enable": true, (esc)
  \t\t"Enable": true, (esc)
  \t\t"Enable": true, (esc)
  \t\t"Name": "eth0", (esc)
  \t\t"Name": "eth1", (esc)
  \t\t"Name": "eth2", (esc)
  \t\t"Name": "eth3", (esc)

Check that we've correct ethernet link details:

  $ R "ubus call Ethernet _get \"{'rel_path':'Link.'}\" | grep -E '(Alias|Enable|Name)' | sort"
  \t\t"Alias": "ETH0", (esc)
  \t\t"Alias": "LAN", (esc)
  \t\t"Alias": "LO", (esc)
  \t\t"Enable": true, (esc)
  \t\t"Enable": true, (esc)
  \t\t"Enable": true, (esc)
  \t\t"Name": "br-lan", (esc)
  \t\t"Name": "eth0", (esc)
  \t\t"Name": "lo", (esc)

Check that IP.Interface provides expected output:

  $ R "ubus call IP _get '{\"rel_path\":\"Interface.\",\"depth\":100}' | jsonfilter -e @[*].Alias -e @[*].Name -e @[*].Status -e @[*].IPAddress -e @[*].SubnetMask | sort"
  127.0.0.1
  192.168.1.1
  192.168.2.1
  255.0.0.0
  255.255.255.0
  255.255.255.0
  ::1
  Disabled
  Down
  Enabled
  Enabled
  Enabled
  Up
  Up
  Up
  br-guest
  br-lan
  eth0
  guest
  guest
  lan
  lan
  lo
  loopback
  loopback_ipv4
  loopbackipv6
  wan

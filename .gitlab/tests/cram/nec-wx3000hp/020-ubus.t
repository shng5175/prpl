Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Check that we've correct system info:

  $ R "ubus call system board | jsonfilter -e @.system -e @.model -e @.board_name"
  GRX500 rev 1.2
  EASY350 ANYWAN (GRX350) Main model
  EASY350 ANYWAN (GRX350) Main model

  $ R "ubus call DeviceInfo _get | jsonfilter -e '@[\"DeviceInfo.\"].ProductClass'"
  EASY350 ANYWAN (GRX350) Main model

Check that we've correct bridge port aliases:

  $ R "ubus call Bridging _get \"{'rel_path':'Bridge.*.Port.*.Alias'}\" | jsonfilter -e @[*].Alias | sort"
  ETH0_1
  ETH0_2
  ETH0_3
  ETH0_4
  ETH1
  ETH2
  ETH3
  GUEST
  bridge
  default_radio10
  default_radio100
  default_radio102
  default_radio11
  default_radio12
  default_radio13
  default_radio42
  default_radio43
  default_radio44
  default_radio45
  default_wl0
  default_wl1

Check that we've correct ethernet interface and link details:

  $ R "ubus call Ethernet _get \"{'rel_path':'Interface.'}\" | grep -E '(Alias|Enable|Name)' | sort"
  \t\t"Alias": "eth0", (esc)
  \t\t"Alias": "eth1", (esc)
  \t\t"Alias": "eth2", (esc)
  \t\t"Alias": "eth3", (esc)
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

  $ R "ubus call Ethernet _get \"{'rel_path':'Link.'}\" | grep -E '(Alias|Enable|Name)' | sort"
  \t\t"Alias": "eth0" (esc)
  \t\t"Alias": "lan" (esc)
  \t\t"Alias": "lo" (esc)
  \t\t"Enable": true, (esc)
  \t\t"Enable": true, (esc)
  \t\t"Enable": true, (esc)
  \t\t"Name": "br-lan", (esc)
  \t\t"Name": "eth0", (esc)
  \t\t"Name": "lo", (esc)

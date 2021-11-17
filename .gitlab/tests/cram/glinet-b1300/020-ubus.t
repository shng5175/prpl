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

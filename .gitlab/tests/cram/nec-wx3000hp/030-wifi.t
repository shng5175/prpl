Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Check for correct SSID setup:

  $ R "iwinfo | grep ESSID"
  wlan0     ESSID: "dummy_ssid_0"
  wlan0.0   ESSID: unknown
  wlan0.1   ESSID: unknown
  wlan0.2   ESSID: unknown
  wlan0.3   ESSID: unknown
  wlan1     ESSID: unknown
  wlan2     ESSID: "dummy_ssid_2"
  wlan2.0   ESSID: unknown
  wlan2.1   ESSID: unknown
  wlan2.2   ESSID: unknown
  wlan2.3   ESSID: unknown
  wlan3     ESSID: unknown

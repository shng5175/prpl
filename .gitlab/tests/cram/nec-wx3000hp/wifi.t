Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Check for correct SSID setup:

  $ R "iwinfo | grep ESSID"
  wlan0     ESSID: "dummy_ssid_0"
  wlan0.0   ESSID: "prplMesh"
  wlan0.1   ESSID: "wave_11"
  wlan0.2   ESSID: "wave_12"
  wlan0.3   ESSID: "wave_13"
  wlan1     ESSID: unknown
  wlan2     ESSID: "dummy_ssid_2"
  wlan2.0   ESSID: "prplMesh"
  wlan2.1   ESSID: "wave_43"
  wlan2.2   ESSID: "wave_44"
  wlan2.3   ESSID: "wave_45"
  wlan3     ESSID: unknown

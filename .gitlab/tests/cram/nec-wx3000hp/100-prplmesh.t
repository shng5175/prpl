Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Start wireless:

  $ R logger -t cram "Start wireless"
  $ R "uci set wireless.radio0.disabled='0'; uci set wireless.radio2.disabled='0'; uci commit; wifi up"
  $ sleep 180

Check that hostapd & supplicant proccess are up after wireless startup:

  $ R logger -t cram "Check that hostapd \& supplicant proccess are up after wireless startup"

  $ R "ps w" | sed -nE 's/.*(\/usr\/sbin\/hostapd.*)/\1/p' | LC_ALL=C sort
  /usr/sbin/hostapd -s -P /var/run/wifi-phy0.pid -B /var/run/hostapd-phy0.conf
  /usr/sbin/hostapd -s -P /var/run/wifi-phy1.pid -B /var/run/hostapd-phy1.conf

  $ R "ps w" | sed -nE 's/.*(\/usr\/sbin\/wpa_supplicant.*)/\1/p' | LC_ALL=C sort
  /usr/sbin/wpa_supplicant -B -b br-lan -P /var/run/wpa_supplicant-wlan1.pid -D nl80211 -i wlan1 -c /var/ru
  /usr/sbin/wpa_supplicant -B -b br-lan -P /var/run/wpa_supplicant-wlan3.pid -D nl80211 -i wlan3 -c /var/ru

Restart prplmesh:

  $ R logger -t cram "Restart prplmesh"
  $ R "/etc/init.d/prplmesh gateway_mode > /dev/null 2>&1 && sleep 180"

Check VAP setup:

  $ R logger -t cram "Check VAP setup"

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

Check that prplmesh processes are running:

  $ R logger -t cram "Check that prplmesh processes are running"

  $ R "ps w" | sed -nE 's/.*(\/opt\/prplmesh\/bin.*)/\1/p' | LC_ALL=C sort
  /opt/prplmesh/bin/beerocks_agent
  /opt/prplmesh/bin/beerocks_controller
  /opt/prplmesh/bin/beerocks_fronthaul -i wlan0
  /opt/prplmesh/bin/beerocks_fronthaul -i wlan2
  /opt/prplmesh/bin/ieee1905_transport

Check that prplmesh is operational:

  $ R logger -t cram "Check that prplmesh is operational"
  $ R "/opt/prplmesh/scripts/prplmesh_utils.sh status" | sed -E 's/.*(\/opt\/prplmesh.*)/\1/' | LC_ALL=C sort
  \x1b[0m (esc)
  \x1b[0m\x1b[1;32mOK Main radio agent operational (esc)
  \x1b[1;32moperational test success! (esc)
  /opt/prplmesh/bin/beerocks_agent
  /opt/prplmesh/bin/beerocks_controller
  /opt/prplmesh/bin/beerocks_controller
  /opt/prplmesh/bin/beerocks_fronthaul
  /opt/prplmesh/bin/beerocks_fronthaul
  /opt/prplmesh/bin/ieee1905_transport
  /opt/prplmesh/scripts/prplmesh_utils.sh: status
  OK wlan0 radio agent operational
  OK wlan2 radio agent operational
  executing operational test using bml

Check that prplmesh is in operational state:

  $ R logger -t cram "Check that prplmesh is in operational state"
  $ R "/opt/prplmesh/bin/beerocks_cli -c bml_conn_map" | egrep '(wlan|OK)' | sed -E "s/.*: (wlan[0-9.]+) .*/\1/" | LC_ALL=C sort
  bml_connect: return value is: BML_RET_OK, Success status
  bml_disconnect: return value is: BML_RET_OK, Success status
  bml_nw_map_query: return value is: BML_RET_OK, Success status
  wlan0
  wlan0.0
  wlan0.1
  wlan0.2
  wlan0.3
  wlan2
  wlan2.0
  wlan2.1
  wlan2.2
  wlan2.3

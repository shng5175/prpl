Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Start wireless:

  $ R logger -t cram "Start wireless"
  $ R "uci set wireless.radio0.disabled='0'; uci set wireless.radio1.disabled='0'; uci commit; wifi up"
  $ sleep 30

Check that hostapd is operating after reboot:

  $ R logger -t cram "Check that hostapd is operating after reboot"
  $ R "ps w" | sed -nE 's/.*(\/usr\/sbin\/hostapd.*)/\1/p' | LC_ALL=C sort
  /usr/sbin/hostapd -s -P /var/run/wifi-phy0.pid -B /var/run/hostapd-phy0.conf
  /usr/sbin/hostapd -s -P /var/run/wifi-phy1.pid -B /var/run/hostapd-phy1.conf

Restart prplmesh:

  $ R logger -t cram "Restart prplmesh"
  $ R "/opt/prplmesh/scripts/prplmesh_utils.sh restart && sleep 5" > /dev/null 2>&1
  $ sleep 60

Check VAP setup after restart:

  $ R logger -t cram "Check VAP setup after restart"
  $ R "iwinfo | grep ESSID"
  wlan0     ESSID: unknown
  wlan1     ESSID: unknown

Check that prplmesh processes are running:

  $ R logger -t cram "Check that prplmesh processes are running"
  $ R "ps w" | sed -nE 's/.*(\/opt\/prplmesh\/bin.*)/\1/p' | LC_ALL=C sort
  /opt/prplmesh/bin/beerocks_agent
  /opt/prplmesh/bin/beerocks_controller
  /opt/prplmesh/bin/beerocks_fronthaul -i wlan0
  /opt/prplmesh/bin/beerocks_fronthaul -i wlan1
  /opt/prplmesh/bin/ieee1905_transport

Check that prplmesh is operational:

  $ R logger -t cram "Check that prplmesh is operational"
  $ R "/opt/prplmesh/scripts/prplmesh_utils.sh status" | sed -E 's/.*(\/opt\/prplmesh.*)/\1/' | LC_ALL=C sort

Check that prplmesh is in operational state:

  $ R logger -t cram "Check that prplmesh is in operational state"
  $ R "/opt/prplmesh/bin/beerocks_cli -c bml_conn_map" | egrep '(wlan|OK)' | sed -E "s/.*: (wlan[0-9.]+) .*/\1/" | LC_ALL=C sort

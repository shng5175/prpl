Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Check that HTTP from LAN is allowed:

  $ curl --silent --output /dev/null --max-time 2 http://$TARGET_LAN_IP

Disable firewall rule for HTTP access from LAN:

  $ script --command "ssh -t root@$TARGET_LAN_IP ubus-cli Firewall.X_Prpl_Service.http.Enable=0" > /dev/null; sleep .5

Check that HTTP from LAN is forbidden:

  $ curl --silent --output /dev/null --max-time 2 http://$TARGET_LAN_IP
  [28]

Enable firewall rule for HTTP access from LAN:

  $ script --command "ssh -t root@$TARGET_LAN_IP ubus-cli Firewall.X_Prpl_Service.http.Enable=1" > /dev/null; sleep .5

Check that HTTP from LAN is allowed:

  $ curl --silent --output /dev/null --max-time 2 http://$TARGET_LAN_IP

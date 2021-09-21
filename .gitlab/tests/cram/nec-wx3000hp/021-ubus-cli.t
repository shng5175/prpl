Check that we've correct system info:

  $ script --command "ssh -t root@$TARGET_LAN_IP 'ubus-cli DeviceInfo.?'" | grep ProductClass
  \x1b[32;1mDeviceInfo.\x1b[0mProductClass="EASY350 ANYWAN (GRX350) Main model"\r (esc)

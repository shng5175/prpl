Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Check that we've correct system info:

  $ R "ubus call system board | jsonfilter -e @.system -e @.model -e @.board_name"
  GRX500 rev 1.2
  EASY550 ANYWAN (GRX550) Main model
  EASY550 ANYWAN (GRX550) Main model

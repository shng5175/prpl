Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Add testing profiles and triggers:

  $ printf "\
  > ubus-cli X_PRPL-COM_MultiSettings.DetectionAtBoot=1
  > ubus-cli X_PRPL-COM_MultiSettings.Profile.+{Alias='france-profile'}
  > ubus-cli X_PRPL-COM_MultiSettings.Profile.france-profile.Name='france'
  > ubus-cli X_PRPL-COM_MultiSettings.Profile.france-profile.ImpactedModules='testing'
  > ubus-cli X_PRPL-COM_MultiSettings.Profile.france-profile.Trigger.+{Alias='country-france'}
  > ubus-cli X_PRPL-COM_MultiSettings.Profile.france-profile.Trigger.country-france.LeftMember='TestingEmitter.CountryCode'
  > ubus-cli X_PRPL-COM_MultiSettings.Profile.france-profile.Trigger.country-france.RelationalOperator='Equal'
  > ubus-cli X_PRPL-COM_MultiSettings.Profile.france-profile.Trigger.country-france.RightMember='FR'
  > ubus-cli X_PRPL-COM_MultiSettings.Profile.+{Alias='usa-profile'}
  > ubus-cli X_PRPL-COM_MultiSettings.Profile.usa-profile.Name='usa'
  > ubus-cli X_PRPL-COM_MultiSettings.Profile.usa-profile.ImpactedModules='testing'
  > ubus-cli X_PRPL-COM_MultiSettings.Profile.usa-profile.Trigger.+{Alias='country-usa'}
  > ubus-cli X_PRPL-COM_MultiSettings.Profile.usa-profile.Trigger.country-usa.LeftMember='TestingEmitter.CountryCode'
  > ubus-cli X_PRPL-COM_MultiSettings.Profile.usa-profile.Trigger.country-usa.RelationalOperator='Equal'
  > ubus-cli X_PRPL-COM_MultiSettings.Profile.usa-profile.Trigger.country-usa.RightMember='US'
  > " > /tmp/cram
  $ script --command "ssh -t root@$TARGET_LAN_IP '$(cat /tmp/cram)'" > /dev/null

Add testing service:

  $ scp -r $TESTDIR/035-multisettings/* root@${TARGET_LAN_IP}:/

Restart multisettings service and start testing service:

  $ R "/etc/init.d/testing start 2> /dev/null"
  $ R "/etc/init.d/multisettings restart 2> /dev/null"

Check that there is no profile currently selected:

  $ R "cat /var/run/selected_profile"
  cat: can't open '/var/run/selected_profile': No such file or directory
  [1]

Check that TestingReceiver and TestingEmitter have correct default settings:

  $ R "ubus call TestingReceiver _get \"{'rel_path':''}\" | jsonfilter -e @[*].NTPServer1 -e @[*].NTPServer2 | sort"
  0.eu.pool.ntp.org
  1.eu.pool.ntp.org

  $ R "ubus call TestingEmitter _get \"{'rel_path':''}\" | jsonfilter -e @[*].CountryCode"
  EU

Change profile to France:

  $ script --command "ssh -t root@$TARGET_LAN_IP ubus-cli TestingEmitter.CountryCode='FR'" > /dev/null; sleep 5

Check that french profile is correctly applied:

  $ R "ubus list | grep TestingReceiver"
  TestingReceiver

  $ R "ubus call TestingReceiver _get \"{'rel_path':''}\" | jsonfilter -e @[*].NTPServer1 -e @[*].NTPServer2 | sort"
  0.fr.pool.ntp.org
  1.fr.pool.ntp.org

Cleanup:

  $ R "/etc/init.d/testing stop 2> /dev/null"
  $ R "/etc/init.d/multisettings stop 2> /dev/null"
  $ R "rm -fr /etc/config/multisettings; rm /etc/init.d/testing"
  $ R "rm -fr /etc/amx/testing; rm -fr /var/run/selected_profile; rm /usr/bin/testing"
  $ R "/etc/init.d/multisettings start 2> /dev/null"

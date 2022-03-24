Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Check that random LXC binaries work:

  $ R /opt/prplos/usr/bin/lxc-info
  lxc-info: No container name specified
  [1]

  $ R /opt/prplos/usr/bin/lxc-device
  lxc-device: No container name specified
  [1]

Check Cthulhu.Config datamodel:

  $ R "ubus -S call Cthulhu.Config _get"
  {"Cthulhu.Config.":{"ImageLocation":"/usr/share/rlyeh/images","StorageLocation":"/usr/share/cthulhu","UseOverlayFS":true,"DhcpCommand":"","DefaultBackend":"/usr/lib/cthulhu-lxc/cthulhu-lxc.so","BlobLocation":"/usr/share/rlyeh/blobs"}}

Check Rlyeh datamodel:

  $ R "ubus -S call Rlyeh _get"
  {"Rlyeh.":{"ImageLocation":"/usr/share/rlyeh/images","SignatureVerification":false,"StorageLocation":"/usr/share/rlyeh/blobs"}}

Check SoftwareModules datamodel:

  $ R "ubus -S call SoftwareModules _get"
  {"SoftwareModules.":{"ExecutionUnitNumberOfEntries":0,"ExecEnvNumberOfEntries":1,"DeploymentUnitNumberOfEntries":0}}

Check Timingila datamodel:

  $ R "ubus -S call Timingila _get"
  {"Timingila.":{"RmAfterUninstall":true,"ContainerPluginPath":"/usr/lib/timingila-cthulhu/timingila-cthulhu.so","PackagerPluginPath":"/usr/lib/timingila-rlyeh/timingila-rlyeh.so","version":"alpha"}}

Check that Rlyeh has no container images:

  $ R "ubus -S call Rlyeh.Images _get"
  {"Rlyeh.Images.":{}}

Check that Rlyeh can download testing container:

  $ R "ubus -S call Rlyeh pull '{\"URI\":\"docker://registry.gitlab.com/prpl-foundation/prplos/prplos/prplos-testing-container-intel_mips-xrx500:v1\",\"UUID\":\"testing\"}'"
  {"retval":""}

Check that Rlyeh has downloaded the testing container:

  $ R "ubus -S call Rlyeh.Images _get | jsonfilter -e @[*].Name -e @[*].Status | sort"
  Downloaded
  prpl-foundation/prplos/prplos/prplos-testing-container-intel_mips-xrx500

Remove testing container:

  $ R "ubus -S call Rlyeh.Images.1 _del"
  {"retval":["Rlyeh.Images.1."]}

Check that Rlyeh has no container images:

  $ R "ubus -S call Rlyeh.Images _get"
  {"Rlyeh.Images.":{}}

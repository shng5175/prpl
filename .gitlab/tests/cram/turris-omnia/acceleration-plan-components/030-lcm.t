Create R alias:

  $ alias R="${CRAM_REMOTE_COMMAND:-}"

Check that Sandbox is not configured properly:

  $ R "ubus -S call Cthulhu.Sandbox.Instances.1.NetworkNS.Interfaces.1 _get"
  [4]

  $ R "ubus -S call Cthulhu.Config _get | jsonfilter -e @[*].DhcpCommand"
  

Configure Sandbox:

  $ cat > /tmp/run-sandbox <<EOF
  > ubus-cli Cthulhu.Config.DhcpCommand=\"udhcpc -r 192.168.1.200 -i\"
  > ubus-cli Cthulhu.Sandbox.Instances.1.NetworkNS.Type="Veth"
  > ubus-cli Cthulhu.Sandbox.Instances.1.NetworkNS.Interfaces.+
  > ubus-cli Cthulhu.Sandbox.Instances.1.NetworkNS.Interfaces.1.Bridge="br-lan"
  > ubus-cli Cthulhu.Sandbox.Instances.1.NetworkNS.Interfaces.1.Interface="eth0"
  > ubus-cli Cthulhu.Sandbox.Instances.1.NetworkNS.Interfaces.1.EnableDhcp=1
  > ubus-cli Cthulhu.Sandbox.Instances.1.NetworkNS.Enable=1
  > ubus-cli "Cthulhu.Sandbox.start(SandboxId=\"generic\")"
  > EOF
  $ script --command "ssh -t root@$TARGET_LAN_IP '$(cat /tmp/run-sandbox)'" > /dev/null
  $ sleep 10

Check that Sandbox was configured properly:

  $ R "ubus -S call Cthulhu.Sandbox.Instances.1.NetworkNS.Interfaces.1 _get"
  {"Cthulhu.Sandbox.Instances.1.NetworkNS.Interfaces.1.":{"EnableDhcp":true,"Interface":"eth0","Bridge":"br-lan"}}

  $ R "ubus -S call Cthulhu.Config _get | jsonfilter -e @[*].DhcpCommand"
  udhcpc -r 192.168.1.200 -i

Install testing prplOS container v1:

  $ cat > /tmp/run-container <<EOF
  > ubus-cli "SoftwareModules.InstallDU(URL=\"docker://registry.gitlab.com/prpl-foundation/prplos/prplos/prplos-testing-container-mvebu-cortexa9:v1\", UUID=\"prplos-testing\", ExecutionEnvRef=\"generic\")"
  > EOF
  $ script --command "ssh -t root@$TARGET_LAN_IP '$(cat /tmp/run-container)'" > /dev/null

Check that prplOS container v1 is running:

  $ sleep 20

  $ R "ubus -S call Cthulhu.Container.Instances.1 _get | jsonfilter -e @[*].Status -e @[*].Bundle -e @[*].BundleVersion -e @[*].ContainerId -e @[*].Alias | sort"
  Running
  cpe-prplos-testing
  prpl-foundation/prplos/prplos/prplos-testing-container-mvebu-cortexa9
  prplos-testing
  v1

  $ R "ssh -y root@192.168.1.200 'cat /etc/container-version' 2> /dev/null"
  1

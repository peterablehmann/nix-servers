{
  config,
  inputs,
  ...
}:
{
  topology.self.interfaces.tailscale0.network = "tailnet";

  sops.secrets."tailscale/authkey" = {
    sopsFile = "${inputs.self}/secrets/common.yaml";
  };

  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets."tailscale/authkey".path;
    useRoutingFeatures = "server";
    extraUpFlags = [
      "--advertise-exit-node"
      "--stateful-filtering"
    ];
  };

  systemd.services.tailscaled.environment = {
    TS_DEBUG_FIREWALL_MODE = "nftables";
  };
}

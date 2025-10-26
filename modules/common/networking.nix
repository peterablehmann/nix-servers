{
  lib,
  config,
  ...
}:
{
  networking = {
    domains = {
      enable = true;
      subDomains = {
        "${config.networking.fqdn}" = { };
      };
      baseDomains."${config.networking.domain}" =
        lib.optionalAttrs (config.metadata.network.ipv4.address != null) {
          a.data = config.metadata.network.ipv4.address;
        }
        // lib.optionalAttrs (config.metadata.network.ipv6.address != null) {
          aaaa.data = config.metadata.network.ipv6.address;
        };
    };
    inherit (config.metadata) hostName domain;
    useNetworkd = true;
    useDHCP = false;
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkDefault false;
    nameservers =
      if
        builtins.elem config.metadata.provider [
          "proxmox.xnee.net"
          "hetzner-cloud"
        ]
      then
        [
          "185.12.64.1"
          "185.12.64.2"
          "2a01:4ff:ff00::add:1"
          "2a01:4ff:ff00::add:2"
        ]
      else if config.metadata.provider == "netcup" then
        [
          "46.38.225.230"
          "46.38.252.230"
          "2a03:4000:0:1::e1e6"
          "2a03:4000:8000::fce6"
        ]
      # Fallback to Quad9 if provider is unknown
      else
        [
          "9.9.9.9"
          "149.112.112.112"
          "2620:fe::fe"
          "2620:fe::9"
        ];
  };
  systemd.network = {
    enable = true;
    networks = {
      "10-wan" = {
        networkConfig = {
          DHCP = false;
          IPv6AcceptRA = false;
        };
        inherit (config.metadata.network.link) matchConfig;
        linkConfig = { inherit (config.metadata.network.link) MTUBytes; };
        address =
          lib.optional (config.metadata.network.ipv4.address != null)
            "${config.metadata.network.ipv4.address}/${builtins.toString config.metadata.network.ipv4.prefixLength}"
          ++
            lib.optional (config.metadata.network.ipv6.address != null)
              "${config.metadata.network.ipv6.address}/${builtins.toString config.metadata.network.ipv6.prefixLength}";
        routes =
          lib.optional (config.metadata.network.ipv4.address != null) (
            {
              Gateway = config.metadata.network.ipv4.gateway;
            }
            // lib.optionalAttrs (config.metadata.provider == "hetzner-cloud") { GatewayOnLink = true; }
          )
          ++ lib.optional (config.metadata.network.ipv6.address != null) {
            Gateway = config.metadata.network.ipv6.gateway;
          };
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}

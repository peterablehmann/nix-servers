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
      baseDomains."${config.networking.domain}" = {
        a.data =
          if config.metadata.network.ipv4.address != null then config.metadata.network.ipv4.address else null;
        aaaa.data =
          if config.metadata.network.ipv6.address != null then config.metadata.network.ipv6.address else null;
      };
    };
    inherit (config.metadata) hostName domain;
    useNetworkd = true;
    useDHCP = false;
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkDefault false;
    nameservers = [
      "185.12.64.1"
      "185.12.64.2"
      "2a01:4ff:ff00::add:1"
      "2a01:4ff:ff00::add:2"
    ];
    timeServers = [ "ntp.hetzner.com" ];
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
        address = [
          (
            if config.metadata.network.ipv4.address != null then
              "${config.metadata.network.ipv4.address}/${builtins.toString config.metadata.network.ipv4.prefixLength}"
            else
              null
          )
          (
            if config.metadata.network.ipv6.address != null then
              "${config.metadata.network.ipv6.address}/${builtins.toString config.metadata.network.ipv6.prefixLength}"
            else
              null
          )
        ];
        routes = [
          (
            if config.metadata.network.ipv4.address != null then
              {
                Gateway = config.metadata.network.ipv4.gateway;
              }
              // (if config.metadata.location == "hetzner-cloud" then { GatewayOnLink = true; } else { })
            else
              null
          )
          (
            if config.metadata.network.ipv6.address != null then
              { Gateway = config.metadata.network.ipv6.gateway; }
            else
              null
          )
        ];
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}

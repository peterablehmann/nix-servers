{
  config,
  lib,
  ...
}:
let
  IPv4 = "128.140.9.158";
  IPv6 = "2a01:4f8:c2c:17c9::1";
in
{
  networking = {
    domains = {
      enable = true;
      subDomains."${config.networking.fqdn}" = { };
      baseDomains."${config.networking.domain}" = {
        a.data = IPv4;
        aaaa.data = IPv6;
      };
    };

    useNetworkd = true;
    useDHCP = false;
    hostName = "ymir";
    usePredictableInterfaceNames = lib.mkDefault false;
    domain = "xnee.net";
    nameservers = [
      "185.12.64.1"
      "185.12.64.2"
      "2a01:4ff:ff00::add:1"
      "2a01:4ff:ff00::add:2"
    ];
    timeServers = [ "ntp.hetzner.com" ];
    dhcpcd.enable = false;
  };
  systemd.network = {
    enable = true;
    networks."10-wan" = {
      networkConfig.DHCP = "no";
      matchConfig.Name = "eth0";
      address = [
        "${IPv4}/32"
        "${IPv6}/64"
      ];
      routes = [
        { Gateway = "fe80::1"; }
        { Destination = "172.31.1.1"; }
        {
          Gateway = "172.31.1.1";
          GatewayOnLink = true;
        }
      ];
      linkConfig.RequiredForOnline = "routable";
    };
  };

  services.tailscale.extraUpFlags = [ "--accept-routes" ];
}

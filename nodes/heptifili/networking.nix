{
  lib,
  config,
  ...
}:
let
  IPv4 = "157.90.190.82";
  IPv6 = "2a01:4f8:1b7:730::3";
in
{
  networking = {
    domains = {
      enable = true;
      subDomains = {
        "${config.networking.fqdn}" = { };
      };
      baseDomains."${config.networking.domain}" = {
        a.data = IPv4;
        aaaa.data = IPv6;
      };
    };
    useNetworkd = true;
    useDHCP = false;
    hostName = "heptifili";
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
    networks = {
      "10-wan" = {
        networkConfig = {
          DHCP = false;
          IPv6AcceptRA = false;
        };
        matchConfig.Name = "eth0";
        linkConfig.MTUBytes = 9216;
        address = [
          "${IPv4}/29"
          "${IPv6}/56"
        ];
        routes = [
          { Gateway = "157.90.190.81"; }
          { Gateway = "2a01:4f8:1b7:700::1"; }
        ];
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}

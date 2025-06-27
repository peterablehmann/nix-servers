{
  lib,
  config,
  ...
}:
let
  IPv4 = "168.119.172.8";
  IPv6 = "2a01:4f8:1c1e:ad66::1";
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
    hostName = "mns";
    usePredictableInterfaceNames = lib.mkDefault false;
    domain = "xnee.net";
    nameservers = [
      #HETZNER
      "2a01:4ff:ff00::add:2"
      "2a01:4ff:ff00::add:1"
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
}

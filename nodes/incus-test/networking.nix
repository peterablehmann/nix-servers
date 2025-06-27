{
  config,
  lib,
  ...
}:
let
  IPv6 = "2a01:4f8:1b7:730::5";
in
{
  networking = {
    hostId = "9b41d34c";
    domains = {
      enable = true;
      subDomains."${config.networking.fqdn}" = { };
      baseDomains."${config.networking.domain}".aaaa.data = IPv6;
    };

    useNetworkd = true;
    useDHCP = false;
    hostName = "incus-test";
    usePredictableInterfaceNames = lib.mkDefault false;
    domain = "xnee.net";
    nameservers = [
      "2a01:4ff:ff00::add:1"
      "2a01:4ff:ff00::add:2"
    ];
    timeServers = [ "ntp.hetzner.com" ];
    dhcpcd.enable = false;
  };
  systemd.network = {
    enable = true;
    networks."10-wan" = {
      networkConfig = {
        DHCP = false;
        IPv6AcceptRA = false;
      };
      matchConfig.Name = "eth0";
      linkConfig.MTUBytes = 9216;
      address = [
        "${IPv6}/56"
      ];
      routes = [
        { Gateway = "2a01:4f8:1b7:700::1"; }
      ];
      linkConfig.RequiredForOnline = "routable";
    };
  };
}

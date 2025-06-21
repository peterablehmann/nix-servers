{
  lib,
  config,
  ...
}:
let
  inherit (config.lib.topology) mkConnectionRev;
  # IPv4 = "192.168.33.1";
  IPv6 = "2a01:4f8:1b7:730::3";
in
{
  topology.self.interfaces.eth0 = {
    network = "Internet";
    physicalConnections = [ (mkConnectionRev "Internet" "*") ];
  };

  networking = {
    domains = {
      enable = true;
      subDomains = {
        "${config.networking.fqdn}" = { };
      };
      baseDomains."${config.networking.domain}" = {
        aaaa.data = IPv6;
      };
    };
    useNetworkd = true;
    useDHCP = false;
    hostName = "heptifili";
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
    networks = {
      "10-wan" = {
        networkConfig = {
          DHCP = false;
          IPv6AcceptRA = false;
        };
        matchConfig.Name = "eth0";
        linkConfig.MTUBytes = 9216;
        address = [
          # "${IPv4}/22"
          "${IPv6}/56"
        ];
        routes = [
          # { Gateway = "192.168.32.1"; }
          { Gateway = "2a01:4f8:1b7:700::1"; }
        ];
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}

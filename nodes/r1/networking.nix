{ config
, inputs
, lib
, ...
}:
let
  inherit (config.lib.topology) mkConnectionRev;
  IPv4 = "78.46.210.123";
  IPv6 = "2a01:4f8:1c1e:8464::1";
in
{
  topology.self.interfaces.eth0 = {
    network = "Internet";
    physicalConnections = [ (mkConnectionRev "Internet" "*") ];
  };

  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

  networking = {
    hostId = "8d51f3b3";
    domains = {
      enable = true;
      subDomains."${config.networking.fqdn}" = { };
      baseDomains."${config.networking.domain}".aaaa.data = "2a0f:85c1:b7a::c0:1";
    };

    useNetworkd = true;
    useDHCP = false;
    hostName = "r1";
    usePredictableInterfaceNames = lib.mkDefault false;
    domain = "as213422.net";
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
    config = {
      addRouteTablesToIPRoute2 = true;
      routeTables = {
        host = 10;
      };
    };
    networks = {
      "01-lo" = {
        matchConfig.Name = "lo";
        address = [ "2a0f:85c1:b7a::c0:1/128" ];
      };
      "10-wan" = {
        networkConfig.DHCP = "no";
        matchConfig.Name = "eth0";
        address = [
          "${IPv4}/32"
          "${IPv6}/128"
        ];
        routes = [
          {
            Gateway = "fe80::1";
            PreferredSource = IPv6;
            Table = "host";
          }
          {
            Gateway = "172.31.1.1";
            PreferredSource = IPv4;
            GatewayOnLink = true;
            Table = "host";
          }
          {
            Destination = "2a11:6c7:4::1/128";
            Gateway = "fe80::1";
          }
          {
            Destination = "2a01:4f8:1c1b:f904::1/128";
            Gateway = "fe80::1";
          }
          {
            Destination = "2a01:4f8:221:3401::100/128";
            Gateway = "fe80::1";
          }
        ];
        routingPolicyRules = [
          {
            To = "${IPv6}";
            Table = "host";
            Priority = 50;
          }
          {
            From = "${IPv6}";
            Table = "host";
            Priority = 50;
          }
          {
            FirewallMark = "0x80";
            Table = "host";
          }
        ];
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };

  sops.secrets = {
    "wireguard/wg212895".sopsFile = "${inputs.self}/secrets/r1.yaml";
    "wireguard/wg213408".sopsFile = "${inputs.self}/secrets/r1.yaml";
    "wireguard/wg213416".sopsFile = "${inputs.self}/secrets/r1.yaml";
  };

  networking.wireguard = {
    enable = true;
    interfaces =
      let
        allowedIPsAsRoutes = false;
        table = "off";
      in
      {
        "wg212895" = {
          inherit allowedIPsAsRoutes table;
          privateKeyFile = config.sops.secrets."wireguard/wg212895".path;
          ips = [
            "fe80::21:2895/64"
            "2a11:6c7:f00:b8::2/64"
          ];
          peers = [{
            name = "peer";
            publicKey = "lgxXREeixNDJ0zdTTSvTgKI1hZuTAxyGvM0NVAad5TI=";
            endpoint = "[2a11:6c7:4::1]:44393";
            persistentKeepalive = 30;
            allowedIPs = [ "::/0" ];
          }];
        };
        "wg213408" = {
          inherit allowedIPsAsRoutes table;
          listenPort = 60001;
          privateKeyFile = config.sops.secrets."wireguard/wg213408".path;
          ips = [
            "fe80::21:3408/64"
            "2a0f:85c1:b7a::c1:2/127"
          ];
          peers = [{
            name = "peer";
            publicKey = "tBisp7mr50xOpdaIO9PoYoYpU+HaRaWF2b8o0+BrmCs=";
            endpoint = "[2a01:4f8:1c1b:f904::1]:60002";
            persistentKeepalive = 30;
            allowedIPs = [ "::/0" ];
          }];
        };
        "wg213416" = {
          inherit allowedIPsAsRoutes table;
          listenPort = 60000;
          privateKeyFile = config.sops.secrets."wireguard/wg213416".path;
          ips = [
            "fe80::21:3416/64"
            "2a0f:85c1:b7a::c1:0/127"
          ];
          peers = [{
            name = "peer";
            publicKey = "tBisp7mr50xOpdaIO9PoYoYpU+HaRaWF2b8o0+BrmCs=";
            endpoint = "[2a01:4f8:221:3401::100]:60000";
            persistentKeepalive = 30;
            allowedIPs = [ "::/0" ];
          }];
        };
      };
  };
}

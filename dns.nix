{ lib
, ...
}:
{
  defaultTTL = 60;
  zones =
    let
      defaults = {
        "" = {
          mx.data = {
            exchange = "www208.your-server.de";
            preference = 10;
          };
          txt.data = [ "v=spf1 mx -all" ];
          ns.data = [
            "hydrogen.ns.hetzner.com"
            "oxygen.ns.hetzner.com"
            "helium.ns.hetzner.de"
          ];
        };
        "_dmarc" = {
          txt.data = "v=DMARC1; p=reject; rua=mailto:dmarc@xnee.net; ruf=mailto:dmarc@xnee.net; adkim=s; aspf=s; fo=0:1:d:s;";
        };
        "default._domainkey" = {
          txt.data = "v=DKIM1; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAw97egS/syiVvNUBjmHfPBZC5cDOO0gFuQHJglRSS9/NqDkXHGc6oWt2reYknIlXJwmKBpisjvULsy2oKl88M0cfAD2iQn6IJc+FASpfqPZSidvaMQnqSq4vgB8wzyvlMZ/7vXWJFnntwZl5H+nG8C29A4LLIR8JEfNpBt5G3VEJbLq6JWoQ4075XjJNNqSe53usNL521zWR/P3ENuQ5k2BvdsuHAUbE76GVaOS118SlGT0Gb6erid75E0pl+wcSAKgtVths8mP03hhL8CaTU5v1EU3ClJL7IF6BkMDwSKyabiC7ohFpRVrNzykXE7nBEAocItpxf2jpC5zhB0AgnSwIDAQAB";
        };
        "autoconfig".cname.data = "mail.your-server.de";
        "_imaps._tcp".srv.data = {
          priority = 0;
          weight = 100;
          port = 993;
          target = "mail.your-server.de";
        };
        "_pop3s._tcp".srv.data = {
          priority = 0;
          weight = 100;
          port = 995;
          target = "mail.your-server.de";
        };
        "_submission._tcp".srv.data = {
          priority = 0;
          weight = 100;
          port = 587;
          target = "mail.your-server.de";
        };
        "_autodiscover._tcp".srv.data = {
          priority = 0;
          weight = 100;
          port = 443;
          target = "mail.your-server.de";
        };
      };
    in
    {
      "as213422.net" = lib.recursiveUpdate defaults {
        "r1.nbg".aaaa.data = "2a0f:85c1:b7a::c0:1";
      };
      "bigdriver.net" = lib.recursiveUpdate defaults { };
      "hainsacker.de" = lib.recursiveUpdate defaults { };
      "lehmann.ing" = lib.recursiveUpdate defaults { };
      "lehmann.zone" = lib.recursiveUpdate defaults {
        "" = {
          a.data = "78.46.0.148";
          aaaa.data = "2a01:4f8:d0a:2160::2";
        };
        "www".cname.data = "lehmann.zone";
        "cloud".cname.data = "nx24177.your-storageshare.de";
      };
      "uic-fahrzeugnummer.de" = lib.recursiveUpdate defaults {
        "" = {
          a.data = "78.46.0.148";
          aaaa.data = "2a01:4f8:d0a:2160::2";
        };
        "www".cname.data = "uic-fahrzeugnummer.de";
      };
      "xnee.de" = lib.recursiveUpdate defaults { };
      "xnee.net" = lib.recursiveUpdate defaults {
        "" = {
          a.data = "78.46.0.148";
          aaaa.data = "2a01:4f8:d0a:2160::2";
          txt.data = [ "TAILSCALE-fMbKHU9GGi8WDXsYeZxJ" ] ++ defaults."".txt.data;
        };
        "www".cname.data = "xnee.net";
        "ip.heptifili".aaaa = {
          data = "fde6:bbc7:8946:7387::2101";
          ttl = 1;
        };
        "kvm1".cname.data = "jetkvm1.tail8b1339.ts.net";
        "yrsa" = {
          a.data = "192.168.32.10";
          aaaa.data = "fde6:bbc7:8946:7387::200a";
        };
        "proxmox" = {
          a.data = [ "192.168.32.10" ];
          aaaa.data = [ "fde6:bbc7:8946:7387::200a" ];
        };
        "fritzbox" = {
          a.data = "192.168.32.1";
          aaaa.data = "fde6:bbc7:8946:7387:6b4:feff:feca:b60b";
        };
        "upptime".cname.data = "peterablehmann.github.io";
        "factorio" = {
          a.data = [ "213.133.102.102" ];
          aaaa.data = [ "2a01:4f8:a0:841d::2" ];
        };
        "_factorio._udp.walistinkt".srv.data = {
          priority = 10;
          weight = 10;
          target = "factorio.xnee.net";
          port = 20108;
        };
      };
    };
}

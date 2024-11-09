{ config
, ...
}:
let
  domain = "sync.xnee.net";
in
{
  security.acme.certs."${domain}" = { };
  networking.domains.subDomains.${domain} = { };

  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    kTLS = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${config.services.syncthing.guiAddress}";
    };
  };

  services.syncthing = {
    enable = true;
    dataDir = "/var/lib/syncthing";
    guiAddress = "[::1]:8384";
    settings = {
      gui.insecureSkipHostcheck = true;
      devices = {
        kleeblatt = {
          name = "kleeblatt.xnee.net";
          id = "XBJODIF-CN5ISJI-3VW6NE4-6EVH6US-3633SA4-EPNVHMI-O3KDIQU-ZL4YDAZ";
        };
        hasenpfote = {
          name = "hasenpfote.xnee.net";
          id = "LAXQGRV-P7YOQLX-OACH3ZD-RHOQHFI-T233PKG-FKVKOMM-HQHM2FT-E7P6FAV";
        };
        durin = {
          name = "durin.xnee.net";
          id = "TWRW63W-65RC4D4-76XRSPS-RCLMBF2-4W3GLAV-4M2DN36-R3BHNZM-ZXDLQAB";
        };
        sleipnir = {
          name = "sleipnir.xnee.net";
          id = "KF4KT6E-7QKG6E6-XI62EOV-PYXNGBS-FYYGWN7-QES3TLA-24K75HH-ZPRSIQ3";
        };
      };
      folders = {
        keepass = {
          id = "56n2x-jhoz6";
          path = "~/keepass";
          devices = [ "kleeblatt" "hasenpfote" "durin" "sleipnir" ];
        };
        obsidianvault = {
          id = "esczl-qkfaz";
          path = "~/obsidianvault";
          devices = [ "kleeblatt" "hasenpfote" "durin" "sleipnir" ];
        };
        dcim = {
          id = "vpehd-xcue1";
          path = "~/dcim";
          devices = [ "kleeblatt" "hasenpfote" "durin" "sleipnir" ];
        };
      };
    };
  };

  backup.paths = [ config.services.syncthing.dataDir ];
}

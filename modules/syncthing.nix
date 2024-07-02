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
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${config.services.syncthing.guiAddress}";
    };
  };

  services.syncthing = {
    enable = true;
    dataDir = "/data/syncthing";
    guiAddress = "127.0.0.1:8384";
    settings = {
      gui.insecureSkipHostcheck = true;
      devices = {
        kleeblatt = {
          name = "kleeblatt.xnee.net";
          id = "5UXRXPX-IC4KO4H-E5KFHRI-ROKQBI4-IORXZZN-S5HHRP2-QSVNN3I-MTQIEAU";
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
}

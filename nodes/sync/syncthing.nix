{ config, lib, pkgs, ... }:
let
  domain = "sync.xnee.de";
in
{
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.caddy = {
    enable = true;
    virtualHosts = {
      "sync.xnee.net" = {
        extraConfig = ''
          reverse_proxy http://localhost:8384 {
            header_up Host {upstream_hostport}
          } 
        '';
      };
    };
  };

  services.syncthing = {
    enable = true;
    dataDir = "/mnt/share";
    guiAddress = "127.0.0.1:8384";
    settings = {
      devices = {
        kleeblatt = {
          name = "kleeblatt.xnee.net";
          id = "ZMOLUG3-6LSPE3R-FRAO253-HEFQ4FC-Y6XS7ED-P5WWKKJ-NHPAL3U-CKOKSAH";
        };
        hasenpfote = {
          name = "hasenpfote.xnee.net";
          id = "LAXQGRV-P7YOQLX-OACH3ZD-RHOQHFI-T233PKG-FKVKOMM-HQHM2FT-E7P6FAV";
        };
        tab_s8_xnee_de = {
          name = "Tab S8";
          id = "TWRW63W-65RC4D4-76XRSPS-RCLMBF2-4W3GLAV-4M2DN36-R3BHNZM-ZXDLQAB";
        };
        win11_desktop_xnee_de = {
          name = "Win11@Desktop";
          id = "7LVG6JG-N7GRS45-B3THPPH-THPNTKJ-SHL5PX2-AMEVKWP-F24PED6-74CWNAV";
        };
      };
      folders = {
        keepass = {
          id = "56n2x-jhoz6";
          path = "~/keepass";
          devices = [ "kleeblatt" "hasenpfote" "tab_s8_xnee_de" "win11_desktop_xnee_de" ];
        };
        obsidianvault = {
          id = "esczl-qkfaz";
          path = "~/obsidianvault";
          devices = [ "kleeblatt" "hasenpfote" "tab_s8_xnee_de" "win11_desktop_xnee_de" ];
        };
        dcim = {
          id = "vpehd-xcue1";
          path = "~/dcim";
          devices = [ "kleeblatt" "hasenpfote" "tab_s8_xnee_de" "win11_desktop_xnee_de" ];
        };
      };
    };
  };
}

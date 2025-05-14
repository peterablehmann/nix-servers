{ pkgs, ... }:
let
  cloudprober = pkgs.callPackage ./cloudprober-pkgs.nix { };
in
{
  imports = [
    ./cloudprober-module.nix
  ];

  services.cloudprober = {
    enable = true;
    package = cloudprober;
    settings = {
      host = "[::1]";
      probe = [
        {
          name = "ping";
          type = "PING";
          targets.host_names = "1.1.1.1,9.9.9.9,hetzner.com";
        }
        {
          name = "cert";
          type = "HTTP";
          http_probe = {
            scheme = "HTTPS";
            method = "GET";
          };
          targets.host_names = "hetzner.com";
        }
      ];
    };
  };
}

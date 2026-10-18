{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  metadata = {
    hostName = "factorio";
    domain = "xnee.net";
    provider = "proxmox.xnee.net";
    network = {
      ipv6 = {
        address = "2a01:4f8:1b7:732::4";
        prefixLength = 64;
        gateway = "2a01:4f8:1b7:732::1";
      };
    };
  };

  services.factorio = {
    enable = true;
    openFirewall = true;
    bind = "::";
    allowedPlayers = [
      "xgwq"
      "faheus"
      "haennetz"
      "crunsher2"
      "lazy-evaluation"
    ];
    admins = [ "xgwq" ];
    game-name = "Bergwerk";
    autosave-interval = 10;
  };

  backup.paths = [ "/var/lib/${config.services.factorio.stateDirName}" ];
}

{ pkgs
, ...
}:
{
  imports = [
    # ./backup.nix
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];

  services.minecraft-server = {
    enable = true;
    eula = true;
    openFirewall = true;
    package = pkgs.papermcServers.papermc-1_20_5;
  };
  backup.paths = [ "/var/lib/minecraft" ];
}

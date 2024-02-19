{
  imports = [
    ./backup.nix
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];

  services.minecraft-server = {
    enable = true;
    eula = true;
    openFirewall = true;
  };
}

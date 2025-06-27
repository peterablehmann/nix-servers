{
  inputs,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];

  metadata = {
    ipv4 = false;
    ipv6 = true;
  };

  virtualisation.incus = {
    enable = true;
    ui.enable = true;
  };
}

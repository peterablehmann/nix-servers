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
    ipv4 = true;
    ipv6 = true;
  };

  virtualisation.incus = {
    enable = true;
    ui.enable = true;
  };
}

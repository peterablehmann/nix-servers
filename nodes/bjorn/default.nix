{
  config,
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

  services.qemuGuest.enable = true;

  sops.secrets."github-runners/nix-as213422".sopsFile =
    "${inputs.self}/secrets/${config.networking.hostName}.yaml";

  services.github-runners = {
    nix-as213422 = {
      enable = true;
      name = "nix-as213422";
      tokenFile = config.sops.secrets."github-runners/nix-as213422".path;
      url = "https://github.com/peterablehmann/nix-as213422";
    };
  };
}

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
    ./networking.nix
  ];

  metadata = {
    ipv4 = true;
    ipv6 = true;
  };

  services.qemuGuest.enable = true;

  sops.secrets = {
    "github-runners/nix-as213422-1".sopsFile =
      "${inputs.self}/secrets/${config.networking.hostName}.yaml";
    "github-runners/nix-as213422-2".sopsFile =
      "${inputs.self}/secrets/${config.networking.hostName}.yaml";
    "github-runners/nix-as213422-3".sopsFile =
      "${inputs.self}/secrets/${config.networking.hostName}.yaml";
    "github-runners/nix-as213422-4".sopsFile =
      "${inputs.self}/secrets/${config.networking.hostName}.yaml";
  };

  services.github-runners =
    let
      extraPackages = with pkgs; [
        openssh
      ];
    in
    {
      nix-as213422-1 = {
        enable = true;
        name = "nix-as213422-1";
        tokenFile = config.sops.secrets."github-runners/nix-as213422-1".path;
        url = "https://github.com/peterablehmann/nix-as213422";
        inherit extraPackages;
      };
      nix-as213422-2 = {
        enable = true;
        name = "nix-as213422-2";
        tokenFile = config.sops.secrets."github-runners/nix-as213422-2".path;
        url = "https://github.com/peterablehmann/nix-as213422";
        inherit extraPackages;
      };
      nix-as213422-3 = {
        enable = true;
        name = "nix-as213422-3";
        tokenFile = config.sops.secrets."github-runners/nix-as213422-3".path;
        url = "https://github.com/peterablehmann/nix-as213422";
        inherit extraPackages;
      };
      nix-as213422-4 = {
        enable = true;
        name = "nix-as213422-4";
        tokenFile = config.sops.secrets."github-runners/nix-as213422-4".path;
        url = "https://github.com/peterablehmann/nix-as213422";
        inherit extraPackages;
      };
    };
}

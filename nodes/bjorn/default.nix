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
    hostName = "bjorn";
    domain = "xnee.net";
    network = {
      ipv4 = {
        address = "157.90.190.83";
        prefixLength = 29;
        gateway = "157.90.190.81";
      };
      ipv6 = {
        address = "2a01:4f8:1b7:730::2";
        prefixLength = 56;
        gateway = "2a01:4f8:1b7:700::1";
      };
    };
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
    "github-runners/offline-kollektiv-xnee-net-1".sopsFile =
      "${inputs.self}/secrets/${config.networking.hostName}.yaml";
    "github-runners/offline-kollektiv-xnee-net-2".sopsFile =
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
      offline-kollektiv-xnee-net-1 = {
        enable = true;
        name = "offline-kollektiv-xnee-net-1";
        tokenFile = config.sops.secrets."github-runners/offline-kollektiv-xnee-net-1".path;
        url = "https://github.com/offline-kollektiv";
        inherit extraPackages;
      };
      offline-kollektiv-xnee-net-2 = {
        enable = true;
        name = "offline-kollektiv-xnee-net-2";
        tokenFile = config.sops.secrets."github-runners/offline-kollektiv-xnee-net-2".path;
        url = "https://github.com/offline-kollektiv";
        inherit extraPackages;
      };
    };
}

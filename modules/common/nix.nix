{ pkgs
, ...
}:
{
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.lix;
    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [
        "https://cache.lix.systems"
      ];
      trusted-public-keys = [
        "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
      ];
    };
    nixPath = [ "nixpkgs=flake:nixpkgs" ];
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
  };
}

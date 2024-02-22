{
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
      experimental-features = [ "nix-command" "flakes" ];
    };
    nixPath = [ "nixpkgs=flake:nixpkgs" ];
  };
}

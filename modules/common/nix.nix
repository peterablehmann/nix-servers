{
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      nix-path = [ "nixpkgs=flake:nixpkgs" ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
  };
}

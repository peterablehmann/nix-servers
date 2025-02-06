{ pkgs
, ...
}:
{
  imports = [
    ./bird.nix
  ];
  environment.defaultPackages = with pkgs; [ pathvector ];
}

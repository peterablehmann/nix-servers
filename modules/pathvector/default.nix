{ pkgs
, ...
}:
{
  environment.defaultPackages = with pkgs; [ pathvector ];
}

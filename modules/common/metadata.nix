{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.metadata = {
    ipv4 = lib.mkOption {
      type = types.bool;
    };
    ipv6 = lib.mkOption {
      type = types.bool;
    };
  };
}

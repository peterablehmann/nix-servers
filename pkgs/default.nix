final: prev:
let
  inherit (prev) callPackage;
in
{
  vyconfigure = callPackage ./vyconfigure { };
}

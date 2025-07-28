{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.metadata = {
    hostName = lib.mkOption {
      type = types.str;
      description = "The hostname of the system.";
    };
    domain = lib.mkOption {
      type = types.str;
      description = "The domain name of the system.";
    };
    location = lib.mkOption {
      type = types.str;
      default = "unknown";
      description = "The physical location of the system.";
    };
    network = {
      link = {
        matchConfig = lib.mkOption {
          type = types.attrsOf types.str;
          default = {
            Name = "eth0";
          };
          description = ''
            Match configuration for the uplink interface.
            This is used to identify the network interface for the uplink.
          '';
        };
        MTUBytes = lib.mkOption {
          type = types.ints.u16;
          default = 1500;
          description = "Maximum Transmission Unit (MTU) in bytes for the uplink interface.";
        };
      };
      ipv4 = {
        address = lib.mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        prefixLength = lib.mkOption {
          type = types.nullOr types.int;
          default = null;
        };
        gateway = lib.mkOption {
          type = types.nullOr types.str;
          default = null;
        };
      };
      ipv6 = {
        address = lib.mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        prefixLength = lib.mkOption {
          type = types.nullOr types.int;
          default = null;
        };
        gateway = lib.mkOption {
          type = types.nullOr types.str;
          default = null;
        };
      };
    };
  };
}

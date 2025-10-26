{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.metadata = {
    hostName = mkOption {
      type = types.str;
      description = "The hostname of the system.";
    };
    domain = mkOption {
      type = types.str;
      description = "The domain name of the system.";
    };
    provider = mkOption {
      type = types.enum [
        "unknown"
        "hetzner-cloud"
        "netcup"
        "proxmox.xnee.net"
        "proxmox.xnee.net-as213422"
      ];
      default = "unknown";
      description = "The the provider of the system.";
    };
    network = {
      link = {
        matchConfig = mkOption {
          type = types.attrsOf types.str;
          default = {
            Name = "eth0";
          };
          description = ''
            Match configuration for the uplink interface.
            This is used to identify the network interface for the uplink.
          '';
        };
        MTUBytes = mkOption {
          type = types.ints.u16;
          default = 1500;
          description = "Maximum Transmission Unit (MTU) in bytes for the uplink interface.";
        };
      };
      ipv4 = {
        address = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        prefixLength = mkOption {
          type = types.nullOr types.int;
          default = null;
        };
        gateway = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
      };
      ipv6 = {
        address = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        prefixLength = mkOption {
          type = types.nullOr types.int;
          default = null;
        };
        gateway = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
      };
    };
  };
}

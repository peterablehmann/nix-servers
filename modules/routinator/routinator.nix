{ config
, lib
, pkgs
, utils
, ...
}:
let
  inherit (lib)
    getExe
    mkEnableOption
    mkPackageOption
    mkOption
    types
    ;
  inherit (utils) escapeSystemdExecArgs;
  cfg = config.services.routinator;
  settingsFormat = pkgs.formats.toml { };
in
{
  options.services.routinator = {
    enable = mkEnableOption "Enable Routinator 3000";

    package = mkPackageOption pkgs "routinator" { };

    extraArgs = mkOption {
      description = ''
        Extra arguments to passed to routinator, see <https://routinator.docs.nlnetlabs.nl/en/stable/manual-page.html#options> for options.";
      '';
      type = types.listOf types.str;
      default = [ ];
      example = [ "--no-rir-tals" ];
    };

    extraServerArgs = mkOption {
      description = ''
        Extra arguments to passed to the server subcommand, see <https://routinator.docs.nlnetlabs.nl/en/stable/manual-page.html#subcmd-server> for options.";
      '';
      type = types.listOf types.str;
      default = [ ];
      example = [ "--rtr-client-metrics" ];
    };

    settings = mkOption {
      type = types.submodule {
        freeformType = settingsFormat.type;
        options = {
          repository-dir = mkOption {
            type = types.path;
            default = "/var/lib/routinator/rpki-cache";
          };
        };
      };
      description = ''
        Configuration for Routinator 3000, see <https://routinator.docs.nlnetlabs.nl/en/stable/manual-page.html#configuration-file> for options.
      '';
      default = { };
    };
  };

  config = {
    environment.etc."routinator.conf".source = settingsFormat.generate "routinator.conf" cfg.settings;

    systemd.services.routinator = {
      description = "Routinator 3000 is free, open-source RPKI Relying Party software made by NLnet Labs.";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      path = with pkgs; [ rsync ];
      serviceConfig = {
        Type = "exec";
        ExecStart = escapeSystemdExecArgs (
          [
            (getExe cfg.package)
            "--config=/etc/routinator.conf"
          ]
          ++ cfg.extraArgs
          ++ [
            "server"
          ]
          ++ cfg.extraServerArgs
        );
        Restart = "on-failure";
        DynamicUser = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        StateDirectory = "routinator";
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
        SystemCallFilter = "@system-service";
      };
    };
  };
}

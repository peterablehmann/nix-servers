{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  inherit (lib)
    filterAttrsRecursive
    getExe
    maintainers
    mkEnableOption
    mkIf
    mkPackageOption
    mkOption
    types
    ;
  inherit (utils) escapeSystemdExecArgs;
  cfg = config.services.cloudprober;
  settingsFormat = pkgs.formats.json { };
in
{
  options.services.cloudprober = {
    enable = mkEnableOption "cloudprober";

    package = mkPackageOption pkgs "cloudprober" { };

    extraArgs = mkOption {
      description = ''
        Extra arguments passed to cloudprober.";
      '';
      type = types.listOf types.str;
      default = [ ];
      example = [ "--logfmt=json" ];
    };

    settings = mkOption {
      type = types.submodule {
        freeformType = settingsFormat.type;
        # options = { };
        # description = ''
        #   Configuration for cloudprober.
        # '';
        # default = { };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.cloudprober = {
      # description = "Routinator 3000 is free, open-source RPKI Relying Party software made by NLnet Labs.";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "exec";
        ExecStart = escapeSystemdExecArgs (
          [
            (getExe cfg.package)
            "--config_file=${
              settingsFormat.generate "cloudprober.json" (filterAttrsRecursive (n: v: v != null) cfg.settings)
            }"
          ]
          ++ cfg.extraArgs
        );
        Restart = "on-failure";
        # CapabilityBoundingSet = [ "" ];
        # DynamicUser = true;
        # LockPersonality = true;
        # MemoryDenyWriteExecute = true;
        # NoNewPrivileges = true;
        # PrivateDevices = true;
        # PrivateTmp = true;
        # ProtectClock = true;
        # ProtectControlGroups = true;
        # ProtectHome = true;
        # ProtectHostname = true;
        # ProtectKernelLogs = true;
        # ProtectKernelModules = true;
        # ProtectKernelTunables = true;
        # ProtectSystem = "strict";
        # RestrictAddressFamilies = [
        #   "AF_INET"
        #   "AF_INET6"
        #   "AF_UNIX"
        # ];
        # RestrictNamespaces = true;
        # RestrictRealtime = true;
        # StateDirectory = "cloudprober";
        # SystemCallArchitectures = "native";
        # SystemCallErrorNumber = "EPERM";
        # SystemCallFilter = "@system-service";
        # UMask = "0027";
      };
    };
  };

  # meta.maintainers = with maintainers; [ xgwq ];
}

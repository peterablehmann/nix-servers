{ config
, lib
, pkgs
, ...
}:

let
  caps = [
    "CAP_NET_ADMIN"
    "CAP_NET_BIND_SERVICE"
    "CAP_NET_RAW"
  ];
in
{
  environment.systemPackages = [ pkgs.bird ];

  systemd.services.bird2 = {
    description = "BIRD Internet Routing Daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "forking";
      Restart = "on-failure";
      User = "bird2";
      Group = "bird2";
      ExecStart = "${pkgs.bird}/bin/bird -c /etc/bird/bird2.conf";
      ExecReload = "${pkgs.bird}/bin/birdc configure";
      ExecStop = "${pkgs.bird}/bin/birdc down";
      RuntimeDirectory = "bird";
      CapabilityBoundingSet = caps;
      AmbientCapabilities = caps;
      ProtectSystem = "full";
      ProtectHome = "yes";
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      PrivateTmp = true;
      PrivateDevices = true;
      SystemCallFilter = "~@cpu-emulation @debug @keyring @module @mount @obsolete @raw-io";
      MemoryDenyWriteExecute = "yes";
    };
  };
  users = {
    users.bird2 = {
      description = "BIRD Internet Routing Daemon user";
      group = "bird2";
      isSystemUser = true;
    };
    groups.bird2 = { };
  };
}

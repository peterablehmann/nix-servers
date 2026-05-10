{
  config,
  lib,
  pkgs,
  ...
}:
{
  sops.secrets."runner/token" = { };
  virtualisation.podman.enable = true;
  systemd.services.forgejo-runner = {
    description = "forgejo actions-runner";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    environment.DOCKER_HOST = "unix:///run/podman/podman.sock";
    path = with pkgs; [ coreutils ];
    serviceConfig = {
      # DynamicUser = true;
      StateDirectory = "forgejo-runner";
      WorkingDirectory = "-/var/lib/forgejo-runner/";

      # forgejo-runner might fail when forgejo is restarted during upgrade.
      Restart = "on-failure";
      RestartSec = 2;

      BindReadOnlyPaths = [ config.sops.secrets."runner/token".path ];

      ExecStart = "${lib.getExe pkgs.forgejo-runner} daemon --url https://git.xnee.net/ --uuid 22a211a8-e507-4e17-8835-6723c6fb2b9d --token-url file://${
        config.sops.secrets."runner/token".path
      } --label lix:docker://git.lix.systems/lix-project/lix";
    };
  };
}

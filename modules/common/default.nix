{ inputs
, ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    ./boot.nix
    ./exporters.nix
    ./nix.nix
    ./ssh.nix
    ./tailscale.nix
    ./users.nix
  ];

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  system.stateVersion = "23.11";
}

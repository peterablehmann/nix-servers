{ inputs
, config
, ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    inputs.nixos-dns.nixosModules.dns
    ./acme.nix
    ./boot.nix
    ./exporters.nix
    ./nginx.nix
    ./nix.nix
    ./ssh.nix
    ./tailscale.nix
    ./users.nix
  ];

  deployment = {
    targetHost = config.networking.fqdn;
  };

  networking.domains.defaultTTL = 60;
  systemd.network.wait-online.ignoredInterfaces = [ "tailscale0" ];
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  networking.nftables.enable = true;

  system.stateVersion = "23.11";
}

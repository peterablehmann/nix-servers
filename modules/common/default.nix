{
  inputs,
  config,
  ...
}:
{
  imports = [
    # inputs.lix-module.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    inputs.nixos-dns.nixosModules.dns
    ./acme.nix
    ./backup
    ./boot.nix
    ./exporters
    ./fail2ban.nix
    ./metadata.nix
    ./networking.nix
    ./nginx.nix
    ./nix.nix
    ./ssh.nix
    ./tailscale.nix
    ./time.nix
    ./users.nix
  ];

  deployment = {
    targetHost = config.networking.hostName;
  };

  console.keyMap = "de";

  networking.domains.defaultTTL = 60;
  systemd.network.wait-online.ignoredInterfaces = [ "tailscale0" ];
  i18n.defaultLocale = "de_DE.UTF-8";

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  networking.nftables.enable = true;

  services.fwupd.enable = true;

  programs.tmux.enable = true;

  system.stateVersion = "23.11";
}

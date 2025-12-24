{
  inputs,
  config,
  lib,
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
  services.getty.helpLine = lib.mkForce (
    if config.networking.domain == "xnee.net" then
      ''
        XX    XX NN   NN EEEEEEE EEEEEEE     NN   NN EEEEEEE TTTTTTT 
         XX  XX  NNN  NN EE      EE          NNN  NN EE        TTT   
          XXXX   NN N NN EEEEE   EEEEE       NN N NN EEEEE     TTT   
         XX  XX  NN  NNN EE      EE      ... NN  NNN EE        TTT   
        XX    XX NN   NN EEEEEEE EEEEEEE ... NN   NN EEEEEEE   TTT                                            
      ''
    else if config.networking.domain == "as213422.net" then
      ''
          AAA    SSSSS   2222    1  333333      44    2222    2222       NN   NN EEEEEEE TTTTTTT 
         AAAAA  SS      222222  111    3333    444   222222  222222      NNN  NN EE        TTT   
        AA   AA  SSSSS      222  11   3333   44  4       222     222     NN N NN EEEEE     TTT   
        AAAAAAA      SS  2222    11     333 44444444  2222    2222   ... NN  NNN EE        TTT   
        AA   AA  SSSSS  2222222 111 333333     444   2222222 2222222 ... NN   NN EEEEEEE   TTT   
      ''
    else
      ""
  );

  networking.domains.defaultTTL = 60;
  systemd.network.wait-online.ignoredInterfaces = [ "tailscale0" ];
  i18n.defaultLocale = "de_DE.UTF-8";

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  networking.nftables.enable = true;

  services.fwupd.enable = true;

  programs.tmux.enable = true;

  system.stateVersion = "23.11";
}

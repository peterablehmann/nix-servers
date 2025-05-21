{
  pkgs,
  config,
  ...
}:
{
  imports = [
    # ./backup.nix
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];

  services.minecraft-server = {
    enable = true;
    eula = true;
    openFirewall = true;
    package = pkgs.papermcServers.papermc-1_21;
  };
  backup.paths = [ "/var/lib/minecraft" ];

  # Fot squaremap
  networking.domains.subDomains.${"map.${config.networking.fqdn}"} = { };
  security.acme.certs.${"map.${config.networking.fqdn}"} = { };
  services.nginx.virtualHosts."map.${config.networking.fqdn}" = {
    useACMEHost = "map.${config.networking.fqdn}";
    kTLS = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8080";
    };
  };
}

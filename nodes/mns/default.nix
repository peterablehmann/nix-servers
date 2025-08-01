{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  metadata = {
    hostName = "mns";
    domain = "xnee.net";
    location = "hetzner-cloud";
    network = {
      ipv4 = {
        address = "168.119.172.8";
        prefixLength = 32;
        gateway = "172.31.1.1";
      };
      ipv6 = {
        address = "2a01:4f8:1c1e:ad66::1";
        prefixLength = 64;
        gateway = "fe80::1";
      };
    };
  };

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

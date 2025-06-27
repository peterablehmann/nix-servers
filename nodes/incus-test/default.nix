{
  config,
  inputs,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];

  metadata = {
    ipv4 = false;
    ipv6 = true;
  };

  security.acme.certs."${config.networking.fqdn}" = { };
  services.nginx.virtualHosts."${config.networking.fqdn}" = {
    useACMEHost = config.networking.fqdn;
    kTLS = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://[::1]:8443";
    };
  };

  virtualisation.incus = {
    enable = true;
    ui.enable = true;
  };
}

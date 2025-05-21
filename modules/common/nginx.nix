{
  config,
  ...
}:
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  services.nginx = {
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    enable = true;
  };
  users.users.${config.services.nginx.user}.extraGroups = [ config.security.acme.defaults.group ];
}

{
  config,
  ...
}:
{
  services.timesyncd = {
    enable = true;
    servers = config.networking.timeServers;
    fallbackServers = null;
  };
}

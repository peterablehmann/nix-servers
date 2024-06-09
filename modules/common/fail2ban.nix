{
  services.fail2ban = {
    enable = true;
    bantime = "1h";
    bantime-increment = {
      enable = true;
      overalljails = true;
      factor = "4";
      maxtime = "1y";
    };
  };
}

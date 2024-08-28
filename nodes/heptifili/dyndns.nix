{ inputs
, config
, pkgs
, ...
}:
{
  sops.secrets."dyndns/hetzner_api_key" = {
    sopsFile = "${inputs.self}/secrets/common.yaml";
  };

  systemd.timers."dyndns" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1m";
      OnUnitActiveSec = "1m";
      Unit = "dyndns.service";
    };
  };

  systemd.services."dyndns" = {
    script = ''
      zone_id=7DbNys3Lx4MWjg4eXEvMG4
      # Get record ids
      # recordid_ipv4=$(${pkgs.curl}/bin/curl -s "https://dns.hetzner.com/api/v1/records?zone_id=$zone_id" -H "Auth-API-Token: $(cat ${config.sops.secrets."dyndns/hetzner_api_key".path})" | ${pkgs.jq}/bin/jq '.records.[] | select(.name=="ip.heptifili") | select(.type=="A") | .id' | tr -d '"') || (err=$?; printf "Get recordid A failed with %s" "$err"; exit 1)
      recordid_ipv6=$(${pkgs.curl}/bin/curl -s "https://dns.hetzner.com/api/v1/records?zone_id=$zone_id" -H "Auth-API-Token: $(cat ${config.sops.secrets."dyndns/hetzner_api_key".path})" | ${pkgs.jq}/bin/jq '.records.[] | select(.name=="ip.heptifili") | select(.type=="AAAA") | .id' | tr -d '"') || (err=$?; printf "Get recordid AAAA failed with %s" "$err"; exit 1)
      # Get in use IP-addresses
      # current_ipv4=$(${pkgs.curl}/bin/curl -s4 https://ip.hetzner.com) || (err=$?; printf "Get current IPv4 failed with %s" "$err"; exit 1)
      current_ipv6=$(${pkgs.curl}/bin/curl -s6 https://ip.hetzner.com) || (err=$?; printf "Get current IPv6 failed with %s" "$err"; exit 1)
      # Get IP-addresses set in DNS
      # dns_ipv4=$(${pkgs.curl}/bin/curl -s "https://dns.hetzner.com/api/v1/records/$recordid_ipv4" -H "Auth-API-Token: $(cat ${config.sops.secrets."dyndns/hetzner_api_key".path})" | ${pkgs.jq}/bin/jq ".record.value" | tr -d '"') || (err=$?; printf "Get A record failed with %s" "$err"; exit 1)
      dns_ipv6=$(${pkgs.curl}/bin/curl -s "https://dns.hetzner.com/api/v1/records/$recordid_ipv6" -H "Auth-API-Token: $(cat ${config.sops.secrets."dyndns/hetzner_api_key".path})" | ${pkgs.jq}/bin/jq ".record.value" | tr -d '"') || (err=$?; printf "Get AAAA record failed with %s" "$err"; exit 1)

      # if [ $current_ipv4 = $dns_ipv4 ]
      # then
      #   echo "IPv4 already up to date"
      # else
      #   echo "$dns_ipv4 => $current_ipv4"
      #   ${pkgs.curl}/bin/curl -s -X "PUT" "https://dns.hetzner.com/api/v1/records/$recordid_ipv4" -H 'Content-Type: application/json' -H "Auth-API-Token: $(cat ${config.sops.secrets."dyndns/hetzner_api_key".path})" -d $'{"value": "'$current_ipv4'", "ttl": 60, "type": "A", "name": "'ip.heptifili'", "zone_id": "'$zone_id'"}' || (err=$?; printf "Updating A record failed with %s" "$err"; exit 1)
      # fi

      if [ $current_ipv6 = $dns_ipv6 ]
      then
        echo "IPv6 already up to date"
      else
        echo "$dns_ipv6 => $current_ipv6"
        ${pkgs.curl}/bin/curl -s -X "PUT" "https://dns.hetzner.com/api/v1/records/$recordid_ipv6" -H 'Content-Type: application/json' -H "Auth-API-Token: $(cat ${config.sops.secrets."dyndns/hetzner_api_key".path})" -d $'{"value": "'$current_ipv6'", "ttl": 60, "type": "AAAA", "name": "'ip.heptifili'", "zone_id": "'$zone_id'"}' || (err=$?; printf "Updating AAAA record failed with %s" "$err"; exit 1)
      fi
      exit 0
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}

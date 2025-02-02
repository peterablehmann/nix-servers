FLAG_IPV4=""
FLAG_IPV6=""

while getopts 46h:z: opt
do
  case $opt in
    4) FLAG_IPV4=true;;
    6) FLAG_IPV6=true;;
    h) declare -r HOSTNAME=${OPTARG};;
    z) declare -r ZONE=${OPTARG};;
    *) exit 1;;
  esac
done

[ -n "$HOSTNAME" ] || [ -n "$ZONE" ] || (echo 'Argument missing please set hostname and domain using -h and -z flag'; exit 1)
[ -n "$FLAG_IPV4" ] || [ -n "$FLAG_IPV6" ] || (echo 'No IP version selected. Please set IP version using -4 and/or -6'; exit 1)

ZONE_ID=$(curl -s "https://dns.hetzner.com/api/v1/zones" -H "Auth-API-Token: $HETZNER_API_KEY" | jq -r --arg ZONE "$ZONE" '.zones.[] | select(.name==$ZONE) | .id')

if [ -n "$FLAG_IPV4" ]; then
  RECORDID_V4=$(curl -s "https://dns.hetzner.com/api/v1/records?zone_id=$ZONE_ID" -H "Auth-API-Token: $HETZNER_API_KEY" | jq -r --arg HOSTNAME "$HOSTNAME" '.records.[] | select(.name==$HOSTNAME) | select(.type=="A") | .id') || (err=$?; printf "Get recordid A failed with %s" "$err"; exit 1)
  CURRENT_V4=$(curl -s4 https://ip.hetzner.com) || (err=$?; printf "Get current IPv4 failed with %s" "$err"; exit 1)
  DNS_V4=$(curl -s "https://dns.hetzner.com/api/v1/records/$RECORDID_V4" -H "Auth-API-Token: $HETZNER_API_KEY" | jq ".record.value") || (err=$?; printf "Get A record failed with %s" "$err"; exit 1)
  if [ "$CURRENT_V4" = "$DNS_V4" ]
  then
    echo "IPv4 already up to date"
  else
    echo "$DNS_V4 => $CURRENT_V4"
    curl -s -X "PUT" "https://dns.hetzner.com/api/v1/records/$RECORDID_V4" \
      -H 'Content-Type: application/json' \
      -H "Auth-API-Token: $HETZNER_API_KEY" \
      -d $'{"value": "'"$CURRENT_V4"'", "ttl": 60, "type": "A", "name": "'"$HOSTNAME"'", "zone_id": "'"$ZONE_ID"'"}' \
      || (err=$?; printf "Updating A record failed with %s" "$err"; exit 1)
  fi
fi

if [ -n "$FLAG_IPV6" ]; then
  RECORDID_V6=$(curl -s "https://dns.hetzner.com/api/v1/records?zone_id=$ZONE_ID" -H "Auth-API-Token: $HETZNER_API_KEY" | jq -r --arg HOSTNAME "$HOSTNAME" '.records.[] | select(.name==$HOSTNAME) | select(.type=="AAAA") | .id') || (err=$?; printf "Get recordid AAAA failed with %s" "$err"; exit 1)
  CURRENT_V6=$(curl -s6 https://ip.hetzner.com) || (err=$?; printf "Get current IPv6 failed with %s" "$err"; exit 1)
  DNS_V6=$(curl -s "https://dns.hetzner.com/api/v1/records/$RECORDID_V6" -H "Auth-API-Token: $HETZNER_API_KEY" | jq ".record.value") || (err=$?; printf "Get AAAA record failed with %s" "$err"; exit 1)
  if [ "$CURRENT_V6" = "$DNS_V6" ]
  then
    echo "IPv6 already up to date"
  else
    echo "$DNS_V6 => $CURRENT_V6"
    curl -s -X "PUT" "https://dns.hetzner.com/api/v1/records/$RECORDID_V6" \
      -H 'Content-Type: application/json' \
      -H "Auth-API-Token: $HETZNER_API_KEY" \
      -d $'{"value": "'"$CURRENT_V6"'", "ttl": 60, "type": "AAAA", "name": "'"$HOSTNAME"'", "zone_id": "'"$ZONE_ID"'"}' \
      || (err=$?; printf "Updating A record failed with %s" "$err"; exit 1)
  fi
fi

{ inputs
, lib
, ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];

  users.users.root.hashedPassword = "$y$j9T$qcP/OrWwKl62J92MeMrHJ/$VD.z5C7Hzyun2yUEiKw6zGk2f1QKJ/HhH/6vKi/BfqC";

  services.frr = {
    bgpd = {
      enable = true;
      extraOptions = [ "-M rpki" ];
    };
    config = ''
      router bgp 213422
        no bgp default ipv4-unicast

        bgp router-id 255.255.255.255
        neighbor upstream peer-group
        neighbor rs peer-group
        neighbor peer peer-group
        neighbor downstream peer-group

        ! Route64
        neighbor 2a11:6c7:f00:b8::1 remote-as 212895
        neighbor 2a11:6c7:f00:b8::1 local-role customer
        neighbor 2a11:6c7:f00:b8::1 peer-group upstream

        ! Lars
        neighbor 2a0f:85c1:b7a::c1:3 remote-as 213408
        neighbor 2a0f:85c1:b7a::c1:3 local-role peer
        neighbor 2a0f:85c1:b7a::c1:3 peer-group peer
        neighbor 2a0f:85c1:b7a::c1:3 maximum-prefix 5

        ! Timo
        neighbor 2a0f:85c1:b7a::c1:1 remote-as 213416
        neighbor 2a0f:85c1:b7a::c1:1 local-role peer strict-mode
        neighbor 2a0f:85c1:b7a::c1:1 peer-group peer
        neighbor 2a0f:85c1:b7a::c1:1 maximum-prefix 5

        address-family ipv6 unicast
          redistribute connected
          aggregate-address 2a0f:85c1:b7a::/48 summary-only route-map rm-tag-downstream
          neighbor upstream activate
          neighbor upstream maximum-prefix 300000
          neighbor upstream route-map rm-upstream-out out
          neighbor upstream route-map rm-upstream-in in

          neighbor peer activate
          neighbor peer route-map rm-peer-out out
          neighbor peer route-map rm-peer-in in
        exit-address-family

        ! ##################################################
        bgp large-community-list standard cm-learnt-upstream permit 213422:0:1
        bgp large-community-list standard cm-learnt-rs permit 213422:0:2
        bgp large-community-list standard cm-learnt-peer permit 213422:0:3
        bgp large-community-list standard cm-learnt-downstream permit 213422:0:4

        ! ##################################################
        route-map rm-tag-downstream permit 10
          description tag routes with downstream community
          set large-community 213422:0:4 additive

        ! ##################################################
        ! Upstream transit ASes
        route-map rm-upstream-out permit 10
          description only customer routes are provided to upstreams/peers
          match large-community cm-learnt-downstream

        route-map rm-upstream-in permit 10
          call rm-internet-in
          set large-community 213422:0:1 additive
        
        ! ##################################################
        ! Peer ASes
        route-map rm-peer-out permit 10
          match large-community cm-learnt-downstream
        
        route-map rm-peer-in permit 10
          call rm-internet-in
          set large-community 213422:0:3

        ! ##################################################

        bgp as-path access-list acl-bogon-asns deny 23456
        bgp as-path access-list acl-bogon-asns deny 64496-131071
        bgp as-path access-list acl-bogon-asns deny 4200000000-4294967295

        ipv6 prefix-list pl-bogons-v6 deny ::/8 le 128
        ipv6 prefix-list pl-bogons-v6 deny 100::/64 le 128
        ipv6 prefix-list pl-bogons-v6 deny 2001:2::/48 le 128
        ipv6 prefix-list pl-bogons-v6 deny 2001:10::/28 le 128
        ipv6 prefix-list pl-bogons-v6 deny 2001:db8::/32 le 128
        ipv6 prefix-list pl-bogons-v6 deny 3fff::/20 le 128
        ipv6 prefix-list pl-bogons-v6 deny 2002::/16 le 128
        ipv6 prefix-list pl-bogons-v6 deny 3ffe::/16 le 128
        ipv6 prefix-list pl-bogons-v6 deny 5f00::/16 le 128
        ipv6 prefix-list pl-bogons-v6 deny fc00::/7 le 128
        ipv6 prefix-list pl-bogons-v6 deny fe80::/10 le 128
        ipv6 prefix-list pl-bogons-v6 deny fec0::/10 le 128
        ipv6 prefix-list pl-bogons-v6 deny ff00::/8 le 128
        ipv6 prefix-list pl-bogons-v6 deny ::/0 ge 49 le 128
        
        route-map rm-internet-in deny 1
          match rpki invalid
        route-map rm-internet-in deny 2
          match as-path acl-bogon-asns
        route-map rm-internet-in deny 3
          match ipv6 address prefix-list pl-bogons-v6
        route-map rm-internet-in permit 65535
      
      rpki
        rpki cache tcp routinator.xnee.net 8282 preference 1
        exit
    '';
  };
}

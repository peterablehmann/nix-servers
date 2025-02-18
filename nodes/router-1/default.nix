{ inputs
, ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];

  services.frr = {
    bgpd = {
      enable = true;
      extraOptions = [ "--no_kernel" ];
    };
    config = ''
      hostname router-1
      log syslog
      service password-encryption
      service integrated-vtysh-config
      !
      hostname router-1
      log syslog warn
      router bgp 213422
        no bgp default ipv4-unicast

        bgp router-id 255.255.255.255
        neighbor upstream peer-group
        neighbor rs peer-group
        neighbor peer peer-group
        neighbor downstream peer-group

        ! Route64
        neighbor 2a11:6c7:f00:b8::1 remote-as 212895
        neighbor 2a11:6c7:f00:b8::1 peer-group upstream

        address-family ipv6 unicast
          redistribute connected
          aggregate-address 2a0f:85c1:b7a::/48 summary-only route-map rm-tag-downstream
          neighbor upstream activate
          neighbor upstream maximum-prefix 300000
          neighbor upstream route-map rm-upstream-out out
          neighbor upstream route-map rm-upstream-in in
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
          description tag imported routes with community
          set large-community 213422:0:1 additive
    '';
  };
}

{ inputs
, ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
    inputs.self.nixosModules.routinator
  ];

  services.bird = {
    enable = true;
    config = ''
      define OWNAS = 213422;
      define OWNIPv6 = 2a0f:85c1:b7a::c0:1;
      define OWNNETSETv6 = [ 2a0f:85c1:b7a::/48 ];

      router id 255.255.255.255;

      protocol device {
          scan time 30;
      }

      protocol kernel {
          scan time 30;

          ipv6 {
              import all;
              export none;
          };
      }

      function should_announce_prefix() {
        if net ~ [ 2a0f:85c1:b7a::/49+, 2a0f:85c1:b7a::/128+ ] then return true;
        return false;
      }

      # Define the Aggregator
      protocol static {
        if should_announce_prefix() then {
          route 2a0f:85c1:b7a::/48 reject;
        }
      }

      template bgp upstream {
        local as OWNAS;
        path metric 1;

        ipv6 {
          import all;
          export filter {
            if ( net ~ OWNNETSETv6 ) then accept;
            reject;
          };
        };
      }

      protocol bgp route64 from upstream {
        neighbor 2a11:6c7:f00:b8::1 as 212895;
      }
    '';
  };
}

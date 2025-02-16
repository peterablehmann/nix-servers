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
      define OWNIPv6 = fdeb:d925:32e2::c0:1;
      define OWNNETSETv6 = [2a0f:85c1:b7a::/48];

      router id 255.255.255.255;

      protocol device {
          scan time 30;
      }

      protocol kernel {
          scan time 30;

          ipv6 {
              import none;
              export filter {
                  if source = RTS_STATIC then reject;
                  krt_prefsrc = OWNIPv6;
                  accept;
              };
          };
      }

      template bgp upstream {
        local as OWNAS;
        path metric 1;

        ipv6 {
          import all;
          export filter {
            if ( net ~ OWNNETSETv6 )
            then accept;
            else reject;          
          };
        };
      }

      protocol bgp route64 from upstream {
        neighbor 2a11:6c7:f00:b8::1 as 212895;
      }
    '';
  };
}

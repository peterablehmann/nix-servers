{ pkgs
, ...
}:
{

  services.bird = {
    enable = true;
    config = ''
      # This is a basic configuration file, which contains boilerplate options and
      # some basic examples. It allows the BIRD daemon to start but will not cause
      # anything else to happen.
      #
      # Please refer to the BIRD User's Guide documentation, which is also available
      # online at http://bird.network.cz/ in HTML format, for more information on
      # configuring BIRD and adding routing protocols.

      # Configure logging
      log syslog all;

      # The Device protocol is not a real routing protocol. It does not generate any
      # routes and it only serves as a module for getting information about network
      # interfaces from the kernel. It is necessary in almost any configuration.
      protocol device {
      }

      # The direct protocol is not a real routing protocol. It automatically generates
      # direct routes to all network interfaces. Can exist in as many instances as you
      # wish if you want to populate multiple routing tables with direct routes.
      protocol direct {
        disabled;		# Disable by default
        ipv4;			# Connect to default IPv4 table
        ipv6;			# ... and to default IPv6 table
      }

      # The Kernel protocol is not a real routing protocol. Instead of communicating
      # with other routers in the network, it performs synchronization of BIRD
      # routing tables with the OS kernel. One instance per table.
      protocol kernel {
        ipv4 {			# Connect protocol to IPv4 table by channel
      #	      table master4;	# Default IPv4 table is master4
      #	      import all;	# Import to table, default is import all
              export all;	# Export to protocol. default is export none
        };
      #	learn;			# Learn alien routes from the kernel
      #	kernel table 10;	# Kernel table to synchronize with (default: main)
      }

      # Another instance for IPv6, skipping default options
      protocol kernel {
        ipv6 { export all; };
      }

      # Static routes (Again, there can be multiple instances, for different address
      # families and to disable/enable various groups of static routes on the fly).
      protocol static {
        ipv4;			# Again, IPv4 channel with default options
      }
    '';
  };
  environment.defaultPackages = with pkgs; [ pathvector ];
}

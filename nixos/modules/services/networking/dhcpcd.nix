{ config, lib, pkgs, ... }:

with lib;

let

  dhcpcd = if !config.boot.isContainer then pkgs.dhcpcd else pkgs.dhcpcd.override { udev = null; };

  # Don't start dhcpcd on explicitly configured interfaces or on
  # interfaces that are part of a bridge.
  ignoredInterfaces =
    map (i: i.name) (filter (i: i.ipAddress != null) (attrValues config.networking.interfaces))
    ++ concatLists (attrValues (mapAttrs (n: v: v.interfaces) config.networking.bridges))
    ++ concatLists (attrValues (mapAttrs (n: v: v.interfaces) config.networking.bonds))
    ++ config.networking.dhcpcd.denyInterfaces;

  # Config file adapted from the one that ships with dhcpcd.
  dhcpcdConf = pkgs.writeText "dhcpcd.conf"
    ''
      # Inform the DHCP server of our hostname for DDNS.
      hostname

      # A list of options to request from the DHCP server.
      option domain_name_servers, domain_name, domain_search, host_name
      option classless_static_routes, ntp_servers, interface_mtu

      # A ServerID is required by RFC2131.
      # Commented out because of many non-compliant DHCP servers in the wild :(
      #require dhcp_server_identifier

      # A hook script is provided to lookup the hostname if not set by
      # the DHCP server, but it should not be run by default.
      nohook lookup-hostname

      # Ignore peth* devices; on Xen, they're renamed physical
      # Ethernet cards used for bridging.  Likewise for vif* and tap*
      # (Xen) and virbr* and vnet* (libvirt).
      denyinterfaces ${toString ignoredInterfaces} lo peth* vif* tap* tun* virbr* vnet* vboxnet*

      ${config.networking.dhcpcd.extraConfig}
    '';

  # Hook for emitting ip-up/ip-down events.
  exitHook = pkgs.writeText "dhcpcd.exit-hook"
    ''
      if [ "$reason" = BOUND -o "$reason" = REBOOT ]; then
          # Restart ntpd.  We need to restart it to make sure that it
          # will actually do something: if ntpd cannot resolve the
          # server hostnames in its config file, then it will never do
          # anything ever again ("couldn't resolve ..., giving up on
          # it"), so we silently lose time synchronisation.
          ${config.systemd.package}/bin/systemctl try-restart ntpd.service

          ${config.systemd.package}/bin/systemctl start ip-up.target
      fi

      #if [ "$reason" = EXPIRE -o "$reason" = RELEASE -o "$reason" = NOCARRIER ] ; then
      #    ${config.systemd.package}/bin/systemctl start ip-down.target
      #fi

      ${config.networking.dhcpcd.runHook}
    '';

in

{

  ###### interface

  options = {

    networking.dhcpcd.denyInterfaces = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
         Disable the DHCP client for any interface whose name matches
         any of the shell glob patterns in this list. The purpose of
         this option is to blacklist virtual interfaces such as those
         created by Xen, libvirt, LXC, etc.
      '';
    };

    networking.dhcpcd.extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
         Literal string to append to the config file generated for dhcpcd.
      '';
    };

    networking.dhcpcd.runHook = mkOption {
      type = types.lines;
      default = "";
      example = "if [[ $reason =~ BOUND ]]; then echo $interface: Routers are $new_routers - were $old_routers; fi";
      description = ''
         Shell code that will be run after all other hooks. See
         `man dhcpcd-run-hooks` for details on what is possible.
      '';
    };

  };


  ###### implementation

  config = mkIf config.networking.useDHCP {

    systemd.services.dhcpcd =
      { description = "DHCP Client";

        wantedBy = [ "network.target" ];

        # Stopping dhcpcd during a reconfiguration is undesirable
        # because it brings down the network interfaces configured by
        # dhcpcd.  So do a "systemctl restart" instead.
        stopIfChanged = false;

        path = [ dhcpcd pkgs.nettools pkgs.openresolv ];

        unitConfig.ConditionCapability = "CAP_NET_ADMIN";

        serviceConfig =
          { Type = "forking";
            PIDFile = "/run/dhcpcd.pid";
            ExecStart = "@${dhcpcd}/sbin/dhcpcd dhcpcd --quiet --config ${dhcpcdConf}";
            ExecReload = "${dhcpcd}/sbin/dhcpcd --rebind";
            Restart = "always";
          };
      };

    environment.systemPackages = [ dhcpcd ];

    environment.etc =
      [ { source = exitHook;
          target = "dhcpcd.exit-hook";
        }
      ];

    powerManagement.resumeCommands =
      ''
        # Tell dhcpcd to rebind its interfaces if it's running.
        ${config.systemd.package}/bin/systemctl reload dhcpcd.service
      '';

  };

}

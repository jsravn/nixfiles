{ config, options, lib, pkgs, ... }:
with lib;
let cfg = config.modules;
    gpgCfg = cfg.shell.gpg;
    homedir = "$XDG_CONFIG_HOME/gnupg";
in {
  options.modules.shell.gpg = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    cacheTTL = mkOption {
      type = types.int;
      default = 1800;
    };
  };

  config = mkIf gpgCfg.enable {
    my = {
      env.GNUPGHOME = homedir;

      # HACK Without this config file you get "No pinentry program" on 20.03.
      #      program.gnupg.agent.pinentryFlavor doesn't appear to work, and this
      #      is cleaner than overriding the systemd unit.
      home.xdg.configFile."gnupg/gpg-agent.conf" = {
        text = ''
          default-cache-ttl ${toString gpgCfg.cacheTTL}
          pinentry-program ${pkgs.pinentry.gtk2}/bin/pinentry
        '';
      };

      home.xdg.configFile."gnupg/gpg.conf".text = ''
        default-key 52C372C72159D6EE
      '';
    };

    programs.gnupg.agent.enable = true;
  };
}

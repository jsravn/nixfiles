{ config, lib, pkgs, ... }:
with lib;
let cfg = config.modules.desktop;
in {
  options.modules.desktop.browsers = {
    default = mkOption {
      type = types.str;
      default = "chromium";
    };

    chromium = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf cfg.enable {
    my.packages = with pkgs; [
      (chromium.override {
        enableWideVine = true;
      })
      firefox-bin
    ];

    my.env.BROWSER = cfg.browsers.default;
  };
}

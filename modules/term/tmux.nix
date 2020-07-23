{ config, lib, pkgs, ... }:
with lib; {
  options.modules.term.tmux = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.modules.term.tmux.enable {
    my = { packages = with pkgs; [ tmux ]; };
  };
}
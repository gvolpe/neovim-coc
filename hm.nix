{ config, lib, ... }:

let
  cfg = config.programs.neovim-coc;
in
with lib; {
  meta.maintainers = [ maintainers.gvolpe ];

  options.programs.neovim-coc = {
    enable = mkEnableOption "Coc-powered NeoVim configuration.";
  };

  config = mkIf cfg.enable {
    imports = [ neovim/default.nix ];
  };
}

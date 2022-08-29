{
  description = "CoC-powered NeoVim configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, home-manager }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      hm = home-manager.lib.homeManagerConfiguration rec {
        inherit pkgs;
        modules = [
          (import ./neovim)
          {
            xdg = {
              enable = true;
              configHome = "/home/gvolpe/.config";
            };
            home = rec {
              stateVersion = "21.03";
              username = "gvolpe";
              homeDirectory = "/home/${username}";
            };
          }
        ];
      };
      # FIXME: don't know if this is possible, see:
      # https://github.com/nix-community/home-manager/issues/3189
      neovim-coc = hm.config.programs.neovim.finalPackage;
    in
    rec {
      apps.${system} = rec {
        nvim = {
          type = "app";
          program = "${packages.${system}.default}/bin/nvim";
        };

        default = nvim;
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ packages.${system}.neovim-coc ];
      };

      nixosModules.hm = {
        imports = [ ./hm.nix ];
      };

      packages.${system} = rec {
        inherit neovim-coc;
        default = neovim-coc;
      };
    };
}

{
  description = "Highly customizable Wayland bar for Sway and Wlroots based compositors.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devshell.url = "github:numtide/devshell";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, devshell, nixpkgs, flake-compat }:
    let
      inherit (nixpkgs) lib;

      systems = [
        "x86_64-linux"
      ];

      pkgsFor = lib.genAttrs systems (system:
        import nixpkgs {
          inherit system;
        });

      mkDate = longDate: (lib.concatStringsSep "-" [
        (builtins.substring 0 4 longDate)
        (builtins.substring 4 2 longDate)
        (builtins.substring 6 2 longDate)
      ]);
    in
    {
      overlays.default = final: prev: {
        waybar = final.callPackage ./nix/default.nix {
          version = prev.waybar.version + "+date=" + (mkDate (self.lastModifiedDate or "19700101")) + "_" + (self.shortRev or "dirty");
        };
      };

      packages = lib.genAttrs systems
        (system:
          (self.overlays.default pkgsFor.${system} pkgsFor.${system})
          // {
            default = self.packages.${system}.waybar;
          });

      devShells = lib.genAttrs systems
        (system:
          let pkgs = import nixpkgs {
            inherit system;

            overlays = [ devshell.overlay ];
          };
          in
          {
            default = pkgs.callPackage ./nix/devshell.nix {};
          });
    };
}

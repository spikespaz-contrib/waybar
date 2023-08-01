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

  outputs = { self, devshell, nixpkgs, ... }:
    let
      lib = nixpkgs.lib.extend (import ./nix/lib.nix);

      systems = [
        "x86_64-linux"
      ];

      pkgsFor = lib.genAttrs systems (system:
        import nixpkgs {
          inherit system;
        });

      packageDate = (lib.mkDate (self.lastModifiedDate or "19700101")) + "_" + (self.shortRev or "dirty");
    in
    {
      overlays.default = final: prev: {
        waybar = final.callPackage ./nix/default.nix {
          version = prev.waybar.version + "+date=" + packageDate;
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

{
  description =
    "Highly customizable Wayland bar for Sway and Wlroots based compositors.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # See <https://github.com/nix-systems/nix-systems>.
    systems.url = "github:nix-systems/default";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.systems.follows = "systems";

    nixfmt.url = "github:serokell/nixfmt";
    nixfmt.inputs.flake-utils.inputs.systems.follows = "systems";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, systems, devshell, nixfmt, ... }:
    let
      lib = nixpkgs.lib.extend (import ./nix/lib.nix);
      eachSystem = lib.genAttrs (import systems);
      pkgsFor = eachSystem (system: import nixpkgs { inherit system; });
      packageDate = (lib.mkDate (self.lastModifiedDate or "19700101")) + "_"
        + (self.shortRev or "dirty");
    in {
      overlays.default = final: prev: {
        waybar = final.callPackage ./nix/default.nix {
          version = prev.waybar.version + "+date=" + packageDate;
        };
      };

      packages = eachSystem (system:
        (self.overlays.default pkgsFor.${system} pkgsFor.${system}) // {
          default = self.packages.${system}.waybar;
        });

      devShells = eachSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ devshell.overlay ];
          };
        in { default = pkgs.callPackage ./nix/devshell.nix { }; });

      formatter = eachSystem (system: nixfmt.packages.${system}.default);
    };
}

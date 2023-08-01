{ pkgs, devshell }:
devshell.mkShell {
  imports = [ "${devshell.extraModulesDir}/language/c.nix" ];
  commands = [{
    package = devshell.cli;
    help = "Per-project developer environments";
  }];
  devshell.packages = with pkgs;
    [
      clang-tools
      gdb
      # from nativeBuildInputs
      gnumake
      meson
      ninja
      pkg-config
      scdoc
    ] ++ (map lib.getDev [
      # from buildInputs
      wayland
      wlroots
      gtkmm3
      libsigcxx
      jsoncpp
      spdlog
      gtk-layer-shell
      howard-hinnant-date
      libxkbcommon
      # optional dependencies
      gobject-introspection
      glib
      playerctl
      python3.pkgs.pygobject3
      libevdev
      libinput
      libjack2
      libmpdclient
      playerctl
      libnl
      libpulseaudio
      sndio
      sway
      libdbusmenu-gtk3
      udev
      upower
      wireplumber

      # from propagated build inputs?
      at-spi2-atk
      atkmm
      cairo
      cairomm
      catch2
      fmt_8
      fontconfig
      gdk-pixbuf
      glibmm
      gtk3
      harfbuzz
      pango
      pangomm
      wayland-protocols
    ]);
  env = with pkgs; [
    {
      name = "CPLUS_INCLUDE_PATH";
      prefix = "$DEVSHELL_DIR/include";
    }
    {
      name = "PKG_CONFIG_PATH";
      prefix = "$DEVSHELL_DIR/lib/pkgconfig";
    }
    {
      name = "PKG_CONFIG_PATH";
      prefix = "$DEVSHELL_DIR/share/pkgconfig";
    }
    {
      name = "PATH";
      prefix = "${wayland.bin}/bin";
    }
    {
      name = "LIBRARY_PATH";
      prefix = "${lib.getLib sndio}/lib";
    }
    {
      name = "LIBRARY_PATH";
      prefix = "${lib.getLib zlib}/lib";
    }
    {
      name = "LIBRARY_PATH";
      prefix = "${lib.getLib howard-hinnant-date}/lib";
    }
  ];
}

{ config, pkgs, lib, ... }:

let
  # Hiddify is not kept in nixpkgs at the moment, so this module does not try to
  # pretend it is a normal nixpkgs package. The helper below installs the latest
  # upstream AppImage into the current user's ~/.local/bin.
  installHiddify = pkgs.writeShellScriptBin "install-hiddify-appimage" ''
    set -euo pipefail

    install_dir="$HOME/.local/bin"
    app_dir="$HOME/.local/share/applications"
    icon_dir="$HOME/.local/share/icons/hicolor/512x512/apps"
    target="$install_dir/Hiddify.AppImage"

    mkdir -p "$install_dir" "$app_dir" "$icon_dir"

    url="https://github.com/hiddify/hiddify-app/releases/latest/download/Hiddify-Linux-x64.AppImage"

    echo "Downloading Hiddify AppImage from upstream GitHub releases..."
    ${pkgs.curl}/bin/curl -L --fail --show-error --progress-bar "$url" -o "$target"
    chmod +x "$target"

    cat > "$app_dir/hiddify.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=Hiddify
Comment=Multi-platform proxy client based on sing-box
Exec=${pkgs.appimage-run}/bin/appimage-run $target
Terminal=false
Categories=Network;
DESKTOP

    echo "Installed: $target"
    echo "Run with: appimage-run $target"
  '';
in
{
  imports = [ ];

  # Required by some proprietary desktop applications and harmless if unused.
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # VPN / proxy clients
    amnezia-vpn
    v2rayn

    # Hiddify support path. Hiddify itself was removed from nixpkgs, so keep the
    # AppImage runner and a helper script instead of adding a broken package name.
    appimage-run
    installHiddify

    # Useful VPN/proxy debugging tools
    curl
    jq
    wireguard-tools
    amneziawg-tools
  ];

  # AmneziaVPN needs a daemon service unit shipped by the package.
  # If the package changes the unit name upstream, check with:
  #   systemctl list-unit-files | grep -i amnezia
  systemd.services.AmneziaVPN = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.amnezia-vpn}/bin/AmneziaVPN-service";
      Restart = "on-failure";
    };
  };

  # Helpful for TUN/TAP based clients. This does not open inbound firewall ports.
  networking.firewall.checkReversePath = "loose";

  # Desktop integration baseline. Keep this if using KDE/GNOME/Hyprland with portals.
  xdg.portal.enable = true;
}

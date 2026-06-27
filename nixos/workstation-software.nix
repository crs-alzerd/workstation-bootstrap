{ config, pkgs, lib, ... }:

let
  # Some Arch package names do not map 1:1 to nixpkgs.
  # Keep fallback selection here instead of breaking nixos-rebuild on one renamed app.
  firstExistingPackage = name: paths:
    let
      existing = builtins.filter (path: lib.hasAttrByPath path pkgs) paths;
    in
      if existing == [ ] then
        lib.warn "workstation-software: package '${name}' is not available in this nixpkgs revision; skipped" [ ]
      else
        [ (lib.attrByPath (builtins.head existing) null pkgs) ];

  libreOfficePackage = firstExistingPackage "libreoffice" [
    [ "libreoffice-qt" ]
    [ "libreoffice-fresh" ]
    [ "libreoffice" ]
  ];

  # Hiddify is not kept in nixpkgs at the moment, so install it as upstream AppImage.
  # This is intentionally a user-level helper: NixOS keeps the runner declarative,
  # while the downloaded AppImage stays in ~/.local/bin.
  installHiddify = pkgs.writeShellScriptBin "install-hiddify-appimage" ''
    set -euo pipefail

    install_dir="$HOME/.local/bin"
    app_dir="$HOME/.local/share/applications"
    target="$install_dir/Hiddify.AppImage"

    mkdir -p "$install_dir" "$app_dir"

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

  # Required for Obsidian, Discord and other proprietary desktop applications.
  nixpkgs.config.allowUnfree = true;

  # package equivalent of Arch/CachyOS zsh setup.
  programs.zsh.enable = true;

  # Flatpak is in the original package list and also useful as a fallback for apps
  # that are not packaged cleanly in nixpkgs.
  services.flatpak.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
  ];

  environment.systemPackages = with pkgs; [
    # Core — from packages/pacman.txt
    git
    gh                  # Arch: github-cli
    stow
    curl
    wget
    unzip
    zip
    rsync
    jq
    tree
    less
    which
    man-db
    man-pages

    # Arch base-devel equivalent
    gcc
    gnumake             # Arch: make
    binutils
    patch
    pkg-config          # Arch: pkgconf
    cmake

    # Shell / terminal
    zsh
    kitty
    starship
    fzf
    ripgrep
    fd
    bat
    eza
    zoxide
    btop
    fastfetch

    # Dev / Neovim / LazyVim dependencies
    neovim
    lazygit
    nodejs              # includes npm in nixpkgs builds
    python3             # Arch: python
    python3Packages.pynvim
    go
    rustc
    cargo
    rustup
    luarocks

    # Desktop apps
    obsidian
    qbittorrent
    telegram-desktop
    discord
    calibre
    flatpak

    # Fonts are also declared in fonts.packages above, but keeping font packages
    # in the profile makes them explicit in package listings.
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji

    # Optional useful tools
    keepassxc
    gnupg
    age
    sops

    # Extra VPN / proxy clients on top of the repository package list
    amnezia-vpn
    appimage-run
    installHiddify

    # Kept because it was previously requested as the Linux desktop analogue of V2RayNG.
    v2rayn

    # VPN/proxy debugging tools
    wireguard-tools
    amneziawg-tools
  ] ++ libreOfficePackage;

  # AmneziaVPN daemon. If upstream changes the unit name, check with:
  #   systemctl list-unit-files | grep -i amnezia
  systemd.services.AmneziaVPN = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.amnezia-vpn}/bin/AmneziaVPN-service";
      Restart = "on-failure";
    };
  };

  # Helpful for TUN/TAP based VPN/proxy clients. This does not open inbound ports.
  networking.firewall.checkReversePath = "loose";

  # Desktop integration baseline for KDE/GNOME/Hyprland with portals.
  xdg.portal.enable = true;
}

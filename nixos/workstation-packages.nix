{ config, pkgs, ... }:

{
  # Some desktop applications in this profile are unfree in nixpkgs.
  nixpkgs.config.allowUnfree = true;

  # Flatpak is kept available because not every GUI VPN/proxy client is packaged
  # cleanly in nixpkgs. Hiddify currently should be installed from upstream
  # Linux AppImage/DEB/RPM release if no nixpkgs package exists for your channel.
  services.flatpak.enable = true;

  environment.systemPackages = with pkgs; [
    # Core
    git
    gh
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
    nodejs
    nodePackages.npm
    python3
    python3Packages.pynvim
    go
    rustup
    gcc
    gnumake
    cmake
    pkg-config
    luarocks

    # Desktop apps
    obsidian
    qbittorrent
    telegram-desktop
    discord
    calibre
    libreoffice-fresh
    flatpak
    appimage-run

    # VPN / proxy clients
    amnezia-vpn
    v2rayn

    # Fonts
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji

    # Security / secrets
    keepassxc
    gnupg
    age
    sops
  ];
}

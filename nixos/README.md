# NixOS workstation software module

This folder contains a minimal NixOS module for VPN/proxy desktop clients:

- `amnezia-vpn` from nixpkgs;
- `v2rayn` from nixpkgs as the Linux desktop equivalent of V2RayNG;
- Hiddify through AppImage, because `hiddify-app` was removed from nixpkgs as unmaintained.

## Usage

Copy `workstation-software.nix` into your NixOS config directory, for example:

```bash
sudo mkdir -p /etc/nixos/modules
sudo cp workstation-software.nix /etc/nixos/modules/workstation-software.nix
```

Import it from `/etc/nixos/configuration.nix`:

```nix
{
  imports = [
    ./hardware-configuration.nix
    ./modules/workstation-software.nix
  ];
}
```

Apply:

```bash
sudo nixos-rebuild switch
```

Install Hiddify AppImage for the current user after rebuild:

```bash
install-hiddify-appimage
```

## Notes

- `v2rayng` is primarily the Android client name. On Linux/NixOS the practical GUI option in nixpkgs is `v2rayn`.
- Hiddify is deliberately handled outside pure nixpkgs here. For a fully reproducible setup, pin a specific Hiddify release asset and hash it with `nix-prefetch-url` or package it as an AppImage derivation.

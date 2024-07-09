{ config, pkgs, ... }:
let
  bitwarden-unfucked = (import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/f9c070a07e2e95f615e2a7bfcb00f1cc66153c23.tar.gz";
    sha256 = "1snnv3s2yf45d214n1mj60if666psb00nnrxvkmawld15sipvk8j";
  }) {
    system = "x86_64-linux";
  }).bitwarden;
in
{
  imports = [
    ./alacritty.nix
    ./bash.nix
    ./flameshot.nix
    ./git.nix
    ./gpg.nix
    ./nix-index.nix
    ./pass.nix
    ./redshift.nix
    ./ssh.nix
    ./tmux.nix
  ];

  home.packages = (with pkgs; [
    (import ./neovim.nix pkgs)
    imv
    htop
    vlc
    pavucontrol
    p7zip
    wireshark
    thunderbird
    zathura
    ripgrep
    jq
    whois
    (python3.withPackages (packages: with packages; [
      ipython
      pwntools
    ]))
    man-pages
    man-pages-posix
    bitwarden-unfucked
    waybar
    git
    qt5.qtwayland
    qt6.qtwayland
    blender
    yt-dlp
    kicad
    slack
    file
    gimp
    magic-wormhole
    kubectl
    kubectx
    wireguard-tools
    gef
    gdb
    mtr
    iotop
    iftop
    nfs-utils
    openssl
    bridge-utils
    nmap
    hexyl
    firefox-wayland
    mattermost-desktop
    element-desktop
    libreoffice
    discord
    obsidian
    virt-viewer
    fd
    colmena
    agenix
    imhex
    tor-browser-bundle-bin
    signal-desktop
    virt-manager
    docker-compose
    ghidra
  ]);
}

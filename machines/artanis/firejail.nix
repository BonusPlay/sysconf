{ pkgs, nixpkgs-unstable, ... }:
{
  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      firefox-wayland = {
        executable = "${pkgs.firefox}/bin/firefox";
        profile = "${pkgs.firejail}/etc/firejail/firefox-wayland.profile";
        extraArgs = [
          "--dbus-user.talk=org.freedesktop.Notifications"  # enable native notifications
          "--dbus-user.talk=org.freedesktop.portal.Desktop" # screen sharing
          "--whitelist=/home/bonus/.config/pipelight-widevine"  # widevine # TODO: FIXME
        ];
      };
      mattermost-desktop = {
        executable = "${pkgs.mattermost-desktop}/bin/mattermost-desktop";
        profile = "${pkgs.firejail}/etc/firejail/mattermost-desktop.profile";
        extraArgs = [
          "--dbus-user.talk=org.freedesktop.Notifications"  # enable native notifications
        ];
      };
      element-desktop = {
        executable = "${pkgs.element-desktop}/bin/element-desktop";
        profile = "${pkgs.firejail}/etc/firejail/element-desktop.profile";
        extraArgs = [
          "--dbus-user.talk=org.freedesktop.Notifications"  # enable native notifications
        ];
      };
      #signal-desktop = {
      #  executable = "${pkgs.signal-desktop}/bin/signal-desktop";
      #  profile = "${pkgs.firejail}/etc/firejail/signal-desktop.profile";
      #};
      discord = {
        executable = "${nixpkgs-unstable.discord}/bin/discord";
        profile = "${pkgs.firejail}/etc/firejail/discord.profile";
        extraArgs = [
          "--dbus-user.talk=org.freedesktop.Notifications"  # enable native notifications
        ];
      };
      #libreoffice = {
      #  executable = "${pkgs.libreoffice}/bin/libreoffice";
      #  profile = "${pkgs.firejail}/etc/firejail/libreoffice.profile";
      #};
    };
  };
}

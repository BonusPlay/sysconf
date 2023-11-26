{ config, pkgs, ... }:
{
  services.dunst = {
    enable = true;
  };
  # TODO: exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock --nofork ie -f -c 212121

  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = "Mod4";
      terminal = "alacritty";
      modes = {
        resize = {
          "Left" = "resize shrink width 10 px";
          "Down" = "resize grow height 10 px";
          "Up" = "resize shrink height 10 px";
          "Right" = "resize grow width 10 px";
          "Escape" = "mode default";
          "Return" = "mode default";
        };
      };
      #bars = [{
      #  command = "${pkgs.waybar}/bin/waybar";
      #}];
      focus.followMouse = false;
      #defaultWorkspace = "workspace number 1";
      window.commands = [
        {
          command = "floating enable";
          criteria = { class = "^Bitwarden$"; };
        }
      ];
      keybindings =
        let
          cfg = config.xsession.windowManager.i3;
          left = "Left";
          up = "Up";
          down = "Down";
          right = "Right";
        in {
          "${cfg.config.modifier}+Return" = "exec ${cfg.config.terminal}";
          "${cfg.config.modifier}+Shift+q" = "kill";
          "${cfg.config.modifier}+d" = "exec --no-startup-id ${pkgs.dmenu}/bin/dmenu_run";

          "${cfg.config.modifier}+${left}" = "focus left";
          "${cfg.config.modifier}+${down}" = "focus down";
          "${cfg.config.modifier}+${up}" = "focus up";
          "${cfg.config.modifier}+${right}" = "focus right";

          "${cfg.config.modifier}+Shift+${left}" = "move left";
          "${cfg.config.modifier}+Shift+${down}" = "move down";
          "${cfg.config.modifier}+Shift+${up}" = "move up";
          "${cfg.config.modifier}+Shift+${right}" = "move right";

          "${cfg.config.modifier}+b" = "splith";
          "${cfg.config.modifier}+v" = "splitv";
          "${cfg.config.modifier}+f" = "fullscreen toggle";
          "${cfg.config.modifier}+a" = "focus parent";

          "${cfg.config.modifier}+s" = "layout stacking";
          "${cfg.config.modifier}+w" = "layout tabbed";
          "${cfg.config.modifier}+e" = "layout toggle split";

          "${cfg.config.modifier}+Shift+space" = "floating toggle";
          "${cfg.config.modifier}+space" = "focus mode_toggle";

          "${cfg.config.modifier}+1" = "workspace number 1";
          "${cfg.config.modifier}+2" = "workspace number 2";
          "${cfg.config.modifier}+3" = "workspace number 3";
          "${cfg.config.modifier}+4" = "workspace number 4";
          "${cfg.config.modifier}+5" = "workspace number 5";
          "${cfg.config.modifier}+6" = "workspace number 6";
          "${cfg.config.modifier}+7" = "workspace number 7";
          "${cfg.config.modifier}+8" = "workspace number 8";
          "${cfg.config.modifier}+9" = "workspace number 9";

          "${cfg.config.modifier}+Shift+1" = "move container to workspace number 1";
          "${cfg.config.modifier}+Shift+2" = "move container to workspace number 2";
          "${cfg.config.modifier}+Shift+3" = "move container to workspace number 3";
          "${cfg.config.modifier}+Shift+4" = "move container to workspace number 4";
          "${cfg.config.modifier}+Shift+5" = "move container to workspace number 5";
          "${cfg.config.modifier}+Shift+6" = "move container to workspace number 6";
          "${cfg.config.modifier}+Shift+7" = "move container to workspace number 7";
          "${cfg.config.modifier}+Shift+8" = "move container to workspace number 8";
          "${cfg.config.modifier}+Shift+9" = "move container to workspace number 9";

          "${cfg.config.modifier}+Shift+c" = "reload";
          "${cfg.config.modifier}+Shift+e" = "${pkgs.i3}/bin/i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'";

          "${cfg.config.modifier}+r" = "mode resize";

          # Screenshot helper
          Print = "exec ${pkgs.flameshot}/bin/flameshot gui";

          XF86AudioRaiseVolume = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5% && ${pkgs.pulseaudio}/bin/pactl get-sink-volume @DEFAULT_SINK@";
          XF86AudioLowerVolume = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5% && ${pkgs.pulseaudio}/bin/pactl get-sink-volume @DEFAULT_SINK@";
          XF86AudioMute = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
          XF86AudioMicMute = "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
          XF86AudioPlay = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          XF86AudioStop = "exec ${pkgs.playerctl}/bin/playerctl stop";
          XF86AudioNext = "exec ${pkgs.playerctl}/bin/playerctl next";
          XF86AudioPrev = "exec ${pkgs.playerctl}/bin/playerctl previous";

          XF86MonBrightnessDown = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
          XF86MonBrightnessUp  = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +5%";

          # Add support for 10th workspace
          "${cfg.config.modifier}+0" = "workspace number 10";
          "${cfg.config.modifier}+Shift+0" = "move container to workspace number 10";

          Scroll_Lock = ''exec "if [ `xset -q | grep 'LED' | awk '{print $10}'` -eq '00000000' ]; then xset led 3; else xset -led 3; fi'';
          "${cfg.config.modifier}+L" = "exec i3lock -e -f -c 212121";
        };
    };
  };

  home.packages = with pkgs; [
  ];
}

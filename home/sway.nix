{ config, pkgs, ... }:
{
  services.mako = {
    enable = true;
    defaultTimeout = 2000;
  };

  # https://github.com/nix-community/home-manager/issues/5311
  wayland.windowManager.sway.checkConfig = false;

  wayland.windowManager.sway = {
    enable = true;
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
      export XDG_CURRENT_DESKTOP=sway
      export CLUTTER_BACKEND=wayland
      export NIXOS_OZONE_WL=1

      if [ "$HOSTNAME" = "zeratul" ]; then
        export WLR_NO_HARDWARE_CURSORS=1
      fi
    '';
    config = {
      modifier = "Mod4";
      left = "Left";
      up = "Up";
      down = "Down";
      right = "Right";
      #menu = "${pkgs.wofi}/bin/wofi --show drun -G -I";
      terminal = "alacritty";
      input = { "type:keyboard" = { xkb_layout = "pl"; }; };
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
      bars = [{
        command = "${pkgs.waybar}/bin/waybar";
      }];
      focus.followMouse = false;
      output = {
        eDP-1 = {
          scale = "1.5";
          bg = "/etc/nixos/files/toss.jpg fill";
        };
      };
      defaultWorkspace = "workspace number 1";
      window.commands = [
        {
          command = "floating enable";
          criteria = { class = "^Bitwarden$"; };
        }
        {
          command = "floating enable";
          criteria = { app_id = "pinentry-qt"; };
        }
      ];
      keybindings =
        let
          cfg = config.wayland.windowManager.sway;
        in {
          "${cfg.config.modifier}+Return" = "exec ${cfg.config.terminal}";
          "${cfg.config.modifier}+Shift+q" = "kill";
          "${cfg.config.modifier}+d" = "exec ${cfg.config.menu}";

          "${cfg.config.modifier}+${cfg.config.left}" = "focus left";
          "${cfg.config.modifier}+${cfg.config.down}" = "focus down";
          "${cfg.config.modifier}+${cfg.config.up}" = "focus up";
          "${cfg.config.modifier}+${cfg.config.right}" = "focus right";

          "${cfg.config.modifier}+Shift+${cfg.config.left}" = "move left";
          "${cfg.config.modifier}+Shift+${cfg.config.down}" = "move down";
          "${cfg.config.modifier}+Shift+${cfg.config.up}" = "move up";
          "${cfg.config.modifier}+Shift+${cfg.config.right}" = "move right";

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

          "${cfg.config.modifier}+Shift+minus" = "move scratchpad";
          "${cfg.config.modifier}+minus" = "scratchpad show";

          "${cfg.config.modifier}+Shift+c" = "reload";
          "${cfg.config.modifier}+Shift+e" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";

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

          "${cfg.config.modifier}+L" = "exec loginctl lock-session";

          # Add support for 10th workspace
          "${cfg.config.modifier}+0" = "workspace number 10";
          "${cfg.config.modifier}+Shift+0" = "move container to workspace number 10";
        };
    };
  };

  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 60 * 1;
        command = "loginctl lock-session";
      }
      {
        timeout = 60 * 5;
        command = "swaymsg 'output * dpms off'";
        resumeCommand = "swaymsg 'output * dpms on'";
      }
      {
        timeout = 60 * 30;
        command = "systemctl suspend";
      }
    ];
    events = [
      {
        event = "lock";
        command = "${pkgs.swaylock}/bin/swaylock -f -c 212121";
      }
      {
        event = "before-sleep";
        command = "loginctl lock-session";
      }
    ];
  };

  programs.waybar = {
    enable = true;
    style = builtins.readFile ../files/waybar.css;
    settings = builtins.fromJSON ( builtins.readFile ../files/waybar.json );
  };

  services.kanshi = {
    enable = true;
    profiles = {};
  };

  home.packages = with pkgs; [
    wdisplays
    wl-clipboard
  ];
}

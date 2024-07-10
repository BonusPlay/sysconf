{ pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    style = builtins.readFile ../files/waybar.css;
    settings = {
      mainBar = {
        layer = "top";
        position = "bottom";
        modules-left = [
          "sway/workspaces"
          "custom/scratchpad-indicator"
          "sway/mode"
        ];
        modules-right = [
          "cpu"
          "temperature"
          "backlight"
          "pulseaudio"
          "bluetooth"
          "network#wifi"
          "battery"
          "clock"
          "tray"
        ];
        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
        };
        "sway/mode" = {
          format = ''<span style="italic">{}</span>'';
        };
        "sway/window" = {
          format = "{}";
          max-length = 50;
          tooltip = false;
        };
        backlight = {
          format = "{icon} {percent}%";
          format-icons = [ "" ];
        };
        battery = {
          states = {
            warning = 30;
            critical = 10;
          };
          format = "{icon} {capacity}%";
          format-icons = {
            discharging = [ "" "" "" "" "" ];
            charging = [ "" ];
            plugged = [ "" ];
          };
        };
        tray = {
          spacing = 5;
        };
        clock = {
          format = "  {:%H:%M   %e %b}";
          tooltip-format = "<big>{:%B %Y}</big>\n<tt><small>{calendar}</small></tt>";
          today-format = "<b>{}</b>";
          timezone = "Europe/Warsaw";
          locale = "en_US.UTF-8";
        };
        cpu = {
          interval = "1";
          format = ''  {max_frequency}GHz <span color="darkgray">| {usage}%</span>'';
          max-length = 15;
          min-length = 13;
          tooltip = false;
        };
        temperature = {
          interval = "4";
          hwmon-path = "/sys/class/hwmon/hwmon1/temp1_input";
          critical-threshold = 74;
          format-critical = "  {temperatureC}°C";
          format = "{icon}  {temperatureC}°C";
          format-icons = [ "" "" "" ];
          max-length = 7;
          min-length = 5;
          tooltip = false;
        };
        "network#wifi" = {
          interface = "wlp166s0";
          format-wifi = "{essid} = {ipaddr}/{cidr} ";
          format-disconnected = " ";
          family = "ipv4";
          tooltip-format-wifi = "  {ifname} @ {essid}\nIP = {ipaddr}/{cidr}\nStrength = {signalStrength}%\nFreq = {frequency}MHz\n {bandwidthUpBits}  {bandwidthDownBits}";
        };
        pulseaudio = {
          scroll-step = 2.5;
          format = "{icon} {volume}% {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = "";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
        };
        "custom/scratchpad-indicator" = {
          interval = 1;
          return-type = "json";
          exec = ''${pkgs.sway}/bin/swaymsg -t get_tree | ${pkgs.jq}/bin/jq --unbuffered --compact-output '( select(.name == "root") | .nodes[] | select(.name == "__i3") | .nodes[] | select(.name == "__i3_scratch") | .focus) as $scratch_ids | [..  | (.nodes? + .floating_nodes?) // empty | .[] | select(.id |IN($scratch_ids[]))] as $scratch_nodes | { text = "\\($scratch_nodes | length)"; tooltip = $scratch_nodes | map("\\(.app_id // .window_properties.class) (\\(.id)) = \\(.name)") | join("\\n") }'';
          format = "{icon} {}";
          format-icons = [ "" ];
        };
      };
    };
  };
}

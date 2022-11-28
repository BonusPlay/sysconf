{
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    extraConfig = ''
      set -g default-terminal "screen-256color"
      set -g renumber-windows on
    '';
  };
}

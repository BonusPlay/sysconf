{
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    extraConfig = ''
      set -g default-terminal "screen-256color"
      set -g renumber-windows on
      unbind-key -T copy-mode-vi v                             # Unbind old
      bind-key -T copy-mode-vi 'v' send -X begin-selection     # Begin selection in copy mode.
      bind-key -T copy-mode-vi 'C-v' send -X rectangle-toggle  # Begin selection in copy mode.
      bind-key -T copy-mode-vi 'y' send -X copy-selection      # Yank selection in copy mode.
    '';
  };
}

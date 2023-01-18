{
  programs.bash = {
    enable = true;
    sessionVariables = {
      EDITOR = "nvim";
    };
    shellAliases = {
      # security
      rm = "rm -I --preserve-root";
      mv = "mv -i";
      cp = "cp -i";
      ln = "ln -i";
      chown = "chown --preserve-root";
      chmod = "chmod --preserve-root";
      chgrp = "chgrp --preserve-root";

      # old habbits die hard
      sudo = "doas";

      # typos
      "cd.." = "cd ..";
      ll = "ls -lh";
      l = "ll";
      lll = "ll";
      la = "ls -lha";
      ":w" = "echo XDDDDDD";
      ":wq" = "echo XDDDDDD";

      # a quick way to get out of current directory
      ".." = "cd ..";
      "..." = "cd ../../../";
      "...." = "cd ../../../../";
      "....." = "cd ../../../../";
      ".1" = "cd ../";
      ".2" = "cd ../../";
      ".3" = "cd ../../../";
      ".4" = "cd ../../../../";
      ".5" = "cd ../../../../..";

      # colors
      grep = "grep --color=auto";
      egrep = "egrep --color=auto";
      fgrep = "fgrep --color=auto";
      watch = "watch --color";

      # ssh on alacritty
      ssh = "TERM=xterm-256color ssh";

      # ty hswaw for this one
      shitssh = "ssh -oKexAlgorithms=+diffie-hellman-group1-sha1 -oHostKeyAlgorithms=+ssh-dss,ssh-rsa -oPubkeyAcceptedKeyTypes=+ssh-rsa";

      agenix = "nix run github:ryantm/agenix -- ";
    };
    initExtra = ''
      mkcd() {
          mkdir "$1"
          cd "$1"
      }

      BASH_PROMPT_COLOR="1;32m";
      BASH_HOST_COLOR="0;38;5;200m";
      export PS1="\[\033[$BASH_PROMPT_COLOR\]\u@\[$(tput sgr0)\]\[\033[$BASH_HOST_COLOR\]\h\[$(tput sgr0)\]\[\033[$BASH_PROMPT_COLOR\]:\w\\$ \[$(tput sgr0)\]"
    '';
  };
}

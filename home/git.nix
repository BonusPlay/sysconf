{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "Bonus";
    userEmail = "root@bonusplay.pl";
    extraConfig = {
      core = {
        autocrlf = false;
        filemode = false;
      };
      submodule = {
        recurse = true;
      };
      init = {
        defaultBranch = "master";
      };
      color = {
        ui = true;
      };
    };
    aliases = {
      pristine = "${pkgs.git}/bin/git reset --hard origin/master && ${pkgs.git}/bin/git clean -ffxd";
    };
    signing = {
      key = "8F9A363420FDFFE0";
      signByDefault = true;
    };
  };
}

{ pkgs, lib, ... }:
let
  # expect name of disk ("sda") as 1st argument
  checkDiskTemp = pkgs.writeShellScript "vibe-check" ''
    ${pkgs.smartmontools}/bin/smartctl --nocheck=standby -A "/dev/$1" | ${pkgs.gawk}/bin/awk '/Temperature_Celsius/ {print $10 * 1000}'
  '';
  mkDiskSensor = name: {
    id = name;
    cmd = {
      exec = checkDiskTemp;
      args = [ name ];
    };
    # once every 30 minutes
    pollingRate = 30 * 60 * 1000;
  };
  mkDiskCurve = name: {
    id = name;
    linear = {
      sensor = name;
      min = 40;
      max = 45;
    };
  };
  disks = [ "sda" "sdb" "sdc" "sdd" "sde" "sdf" ];
in
{
  custom.fan2go = {
    enable = true;
    settings = {
      fans = [
        {
          id = "sys";
          hwmon = {
            platform = "it8613-*";
            rpmChannel = 3;
          };
          neverStop = true;
          curve = "disk_curve";
        }
      ];
      sensors = map mkDiskSensor disks;
      curves = [
        {
          id = "disk_curve";
          function = {
            type = "maximum";
            curves = disks;
          };
        }
      ] ++ (map mkDiskCurve disks);
    };
  };
}

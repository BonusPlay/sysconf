{ pkgs, lib, ... }:
let
  # expect name of disk ("sda") as 1st argument
  checkDiskTemp = pkgs.writeShellScript "vibe-check" ''
    ${pkgs.smartmontools}/bin/smartctl -a "/dev/$1" | ${pkgs.gawk}/bin/awk '/Temperature_Celsius/ {print $10 * 1000}'
  '';
  mkDiskSensor = name: {
    id = name;
    cmd = {
      exec = checkDiskTemp;
      args = [ name ];
    };
  };
  mkDiskCurve = name: {
    id = name;
    linear = {
      sensor = name;
      min = 30;
      max = 45;
    };
  };
  disks = [ "sda" "sdb" "sdc" ];
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

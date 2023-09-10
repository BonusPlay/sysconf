{ config, pkgs, lib, ... }:
{
  age.secrets.taigaEnv = {
    file = ../../secrets/taiga-env.age;
    mode = "0400";
  };
}

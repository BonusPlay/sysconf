{ config, pkgs, lib, ... }:
{
  age.secrets.taigaEnv = {
    file = ../../secrets/taiga-secrets.age;
    mode = "0400";
  };
}

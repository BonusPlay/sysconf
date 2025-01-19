{ config, pkgs, ... }:
let
  package = (pkgs.home-assistant.override {
    extraPackages = py: with py; [ numpy ];
    packageOverrides = final: prev: {
      certifi = prev.certifi.override {
        cacert = pkgs.cacert.override {
          extraCertificateFiles = [ ../../files/warp-net-root.crt ];
        };
      };
    };
  }).overrideAttrs (oldAttrs: {
    doInstallCheck = false;
  });

  pyuptimekuma-hass = pkgs.callPackage ./pyuptimekuma-hass.nix { python3Packages = pkgs.home-assistant.python.pkgs; };
  uptime-kuma-integration = pkgs.callPackage ./uptime-kuma-integration.nix { inherit pyuptimekuma-hass; };
in
{
  custom.nginx.entries = [
    {
      entrypoints = [ "100.84.139.31" ];
      domain = "has.warp.lan";
      target = config.services.home-assistant.config.http.server_host;
      port = config.services.home-assistant.config.http.server_port;
    }
  ];

  age.secrets.home-assistant-secrets = {
    file = ../../secrets/home-assistant-secrets.age;
    path = "${config.services.home-assistant.configDir}/secrets.yaml";
    owner = "hass";
    mode = "0400";
  };

  services.home-assistant = {
    enable = true;
    package = package;
    extraComponents = [
      "default_config"
      "met"
      "esphome"
      "tasmota"
    ];
    customComponents = [
      uptime-kuma-integration
    ];
    config = {
      homeassistant = {
        name = "Home";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        unit_system = "metric";
        time_zone = "!secret timezone";
      };
      default_config = {};
      frontend = {
        themes = "!include_dir_merge_named themes";
      };
      http = {
        base_url = "https://has.warp.lan";
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" ];
        server_port = 8123;
        server_host = "127.0.0.1";
      };
    };
  };
}

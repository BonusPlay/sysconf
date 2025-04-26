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
  services.home-assistant = {
    enable = true;
    package = package;
    extraComponents = [
      "default_config"
      "met"
      "esphome"
      "speedtestdotnet"
      "plex"
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
        external_url = "https://has.bonus.re";
        internal_url = "https://has.bonus.re";
      };
      notify = [
        {
          name = "ntfy";
          platform = "rest";
          method = "POST_JSON";
          authentication = "basic";
          username = "!secret ntfy_username";
          password = "!secret ntfy_password";
          data.topic = "has-general";
          title_param_name = "title";
          message_param_name = "message";
          resource = "https://ntfy.warp.lan";
        }
      ];
      default_config = {};
      frontend = {
        themes = "!include_dir_merge_named themes";
      };
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [ "192.168.116.29" ];
        server_port = 8123;
        server_host = "0.0.0.0";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.home-assistant.config.http.server_port ];

  age.secrets.home-assistant-secrets = {
    file = ../../secrets/home-assistant-secrets.age;
    path = "${config.services.home-assistant.configDir}/secrets.yaml";
    owner = "hass";
    mode = "0400";
  };
}

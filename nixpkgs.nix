inputs: system: import inputs.nixpkgs {
  inherit system;
  overlays = import ./overlays inputs;
  config.allowUnfree = true;
  config.permittedInsecurePackages = [
    "olm-3.2.16" # not much we can do about this one
    "python3.12-ecdsa-0.19.1" # nexus/esptool fails to build without this, which esphome needs
  ];
  config.allowUnfreePredicate = pkg: builtins.elem (system.lib.getName pkg) [
    "corefonts"
  ];
}

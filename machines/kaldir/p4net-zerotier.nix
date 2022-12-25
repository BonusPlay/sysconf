{
  nixpkgs.config.allowUnfree = true;

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "b15644912e097589" ];
  };
}

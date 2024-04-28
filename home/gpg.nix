{ pkgs, ... }:
{
  programs.gpg = {
    enable = true;
    scdaemonSettings.disable-ccid = true;

    # hardening
    # https://www.designed-cybersecurity.com/tutorials/harden-gnupg-config/
    settings = {
      no-comments = true;
      no-emit-version = true;
      keyid-format = "long";
      with-fingerprint = true;
      default-recipient-self = true;
      require-cross-certification = true;
      personal-cipher-preferences = "AES256 AES192 AES";
      personal-digest-preferences = "SHA512 SHA384 SHA256 SHA224";
      personal-compress-preferences = "BZIP2 ZLIB ZIP Uncompressed";
      cert-digest-algo = "SHA512";
      default-preference-list = "AES256 AES192 AES SHA512 SHA384 SHA256 SHA224 BZIP2 ZLIB ZIP Uncompressed";
    };
  };

  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    enableFishIntegration = false;
    enableSshSupport = true;
    enableZshIntegration = false;
    pinentryPackage = pkgs.pinentry-qt;

    # hardening
    # https://www.designed-cybersecurity.com/tutorials/harden-gnupg-config/
    defaultCacheTtl = 300;
    defaultCacheTtlSsh = 300;
    maxCacheTtl = 900;
    maxCacheTtlSsh = 900;
  };

  # use gpg-agent as ssh-agent, for some reason needed for yubikey
  programs.bash.initExtra = ''
    gpg-connect-agent updatestartuptty /bye > /dev/null
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';
}

{
  services.homebox.enable = true;
  # TODO: remove after overlay
  services.homebox.settings = {
    HBOX_DATABASE_DRIVER = "sqlite3";
    HBOX_DATABASE_SQLITE_PATH = "/var/lib/homebox/data/homebox.db?_pragma=busy_timeout=999&_pragma=journal_mode=WAL&_fk=1";
    HBOX_OPTIONS_ALLOW_REGISTRATION = "true";
    HBOX_OPTIONS_CHECK_GITHUB_RELEASE = "false";
  };
  networking.firewall.allowedTCPPorts = [ 7745 ];
}

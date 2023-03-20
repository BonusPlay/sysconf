{
  services.hedgedoc = {
    enable = true;
    settings = {
      db = {
        dialect = "sqlite";
        storage = "/var/lib/hedgedoc/db.hedgedoc.sqlite";
      };
      domain = "md.kncyber.pl";
      protocolUseSSL = true;
      port = 3010;

      oauth2 = {
        userProfileURL = "https://keycloak.kncyber.pl/auth/realms/leaks/protocol/openid-connect/userinfo";
        userProfileUsernameAttr = "preferred_username";
        userProfileEmailAttr = "email";
        userProfileDisplayNameAttr = "name";
        tokenURL = "https://keycloak.kncyber.pl/auth/realms/leaks/protocol/openid-connect/token";
        authorizationURL = "https://keycloak.kncyber.pl/auth/realms/leaks/protocol/openid-connect/auth";
        providerName = "Keycloak";
        clientSecret = "";
        clientID = "hedgedoc";
      };

      # disable email signup
      email = false;
      allowEmailRegister = false;

      # security
      allowFreeURL = false;
      allowAnonymousEdits = false;
      allowAnonymous = false;
      defaultPermission = "limited";
      requireFreeURLAuthentication = true;

      documentMaxLength = 10000000;
    };
  };
}

let
  bonus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFp8/Py31fozDvpKgvfn2lN5xYOggIo1F90DjxdhEbE5";
  users = [ bonus ];

  artanis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDoHqwLsvv8YPig397EeuiSfh7c/4meVfy9ptEt5qt9a";
  kaldir = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBlMeDxPYW6dBbDfeCbfpn5UJpPHjyoE7NJQitfuKVPy";
  braxis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKUkgnjpgtrJOg9oIIsxE8mmmmmc8KsSfirQu+cD4u/n";
  endion = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINuVWjxEUNQaP1Ie0p8vj8AEZNPorbwP25MuUmm7j6A/";
  shakuras = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA24tqea9vBJLiTMCgJV7q6UwKHdZAaiL8cUUO5bNd0A";
  glacius = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEAjgL7ZGbCxc0XG0Lf3FViJLgKwBcaEYFeUrnd8Rroe";
  moria = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMc8a5YtCK/C0cS962UESqvJ9Ap1u/7ipza9p1ah16MQ";
  zhakul = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOPO4gx3kfwSmuP5QGhx7M0dMEComlnf4/IWDkj+bkGE";
  warpprism = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDd9N8Cd/3cQGe+vxCCy4Ct7W06kUylfA7GJjozYnjUU";
  scv = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDytxrtFGC30xkdBCPqAyUROA78eLN/PTBXt2v+HZcmg";
  bunker = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzqBZOdyFfHH66glHDBvY842uQRapJefBk6hVzQM9cQ";
  raven = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPG39FzpJhP42iVzhy3dpmZyqRuKbbi94ckMLv5QWvoY";
  nexus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICGcl8ii1XpeEIn31+Z5gQR66SJJGlP0xi0kuBMGUxpv";
  droid = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHIhBSTW2lG6Hv5AxDyD814NSvnfzB0zsQf697na9eP8";

  vortex-alpha = "";
  vortex-beta = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIARXsFJHnnFuMA8krwgEkuK1BLTJnYnYQoCwmtD9QMUH";
  vortex-gamma = "";

  vortex = [ vortex-beta ];
  servers = vortex ++ [ kaldir braxis endion shakuras glacius moria zhakul warpprism scv bunker raven nexus droid ];

  zeratul = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9lpLAJBIP9qSneD5SbfsPp4lMa3xbeldDbWP+UmBiW";
in
{
  "ca/password-file.age".publicKeys = users ++ [ raven ];
  "ca/intermediate-crt.age".publicKeys = users ++ [ raven ];
  "ca/intermediate-key.age".publicKeys = users ++ [ raven ];

  "cloudflare.age".publicKeys = users ++ [ kaldir endion moria zhakul bunker ];
  "cloudflare-tunnel.age".publicKeys = users;
  "cloudflare/authentik-tunnel.age".publicKeys = users ++ [ braxis ];
  "cloudflare/hedgedoc-tunnel.age".publicKeys = users ++ [ braxis ];
  "cloudflare/vikunja-tunnel.age".publicKeys = users ++ [ braxis ];
  "cloudflare/nextcloud-tunnel.age".publicKeys = users ++ [ bunker ];

  "docker-registry-users.age".publicKeys = users ++ [ kaldir ];
  "docker-registry-service-account.age".publicKeys = users;

  "gitea-runner-linux-token.age".publicKeys = users ++ [ shakuras ];

  "home-assistant-secrets.age".publicKeys = users ++ [ nexus ];

  "litellm-env.age".publicKeys = users ++ [ kaldir ];

  "matrix/synapse-extra-config.age".publicKeys = users ++ [ kaldir ];
  "matrix/synapse-signing-key.age".publicKeys = users ++ [ kaldir ];
  "matrix/meta-registration.age".publicKeys = users ++ [ kaldir ];
  "matrix/meta-environment.age".publicKeys = users ++ [ kaldir ];
  "matrix/telegram-registration.age".publicKeys = users ++ [ kaldir ];
  "matrix/telegram-environment.age".publicKeys = users ++ [ kaldir ];
  "matrix/slack-registration.age".publicKeys = users ++ [ kaldir ];
  "matrix/slack-environment.age".publicKeys = users ++ [ kaldir ];
  "matrix/sliding-sync-environment.age".publicKeys = users ++ [ kaldir ];

  "nextcloud/admin-pass.age".publicKeys = users ++ [ bunker ];
  "nextcloud/basic-auth.age".publicKeys = users ++ [ bunker ];
  "nextcloud/ssl-key.age".publicKeys = users ++ [ bunker ];
  "nextcloud/onlyoffice-jwt.age".publicKeys = users ++ [ bunker ];
  "nextcloud/s3-secret.age".publicKeys = users ++ [ bunker ];

  "kncyber/authentik-env.age".publicKeys = users ++ [ braxis ];
  "kncyber/hedgedoc-env.age".publicKeys = users ++ [ braxis ];
  "kncyber/discord-bot.age".publicKeys = users ++ [ braxis ];
  "kncyber/vikunja-config.age".publicKeys = users ++ [ braxis ];

  "grafana-alloy.age".publicKeys = users ++ servers;
  "scv-key.age".publicKeys = users ++ servers ++ [ artanis zeratul ];
  "beszel-env.age".publicKeys = users ++ servers;

  "obsidian-env.age".publicKeys = users ++ [ kaldir ];

  "garage-env.age".publicKeys = users ++ vortex;

  "wifi.age".publicKeys = users ++ [ artanis ];
}

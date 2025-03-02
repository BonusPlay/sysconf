let
  bonus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFp8/Py31fozDvpKgvfn2lN5xYOggIo1F90DjxdhEbE5";
  users = [ bonus ];

  kaldir = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBlMeDxPYW6dBbDfeCbfpn5UJpPHjyoE7NJQitfuKVPy";
  braxis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKUkgnjpgtrJOg9oIIsxE8mmmmmc8KsSfirQu+cD4u/n";
  endion = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINuVWjxEUNQaP1Ie0p8vj8AEZNPorbwP25MuUmm7j6A/";
  shakuras = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA24tqea9vBJLiTMCgJV7q6UwKHdZAaiL8cUUO5bNd0A";
  glacius = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIY8XAAact/o1QSOfmwJOEGb7cvcDXX6BUUMCKkeNnu5";
  warpprism = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDd9N8Cd/3cQGe+vxCCy4Ct7W06kUylfA7GJjozYnjUU";
  scv = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDytxrtFGC30xkdBCPqAyUROA78eLN/PTBXt2v+HZcmg";
  bunker = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzqBZOdyFfHH66glHDBvY842uQRapJefBk6hVzQM9cQ";
  raven = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPG39FzpJhP42iVzhy3dpmZyqRuKbbi94ckMLv5QWvoY";
  nexus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICGcl8ii1XpeEIn31+Z5gQR66SJJGlP0xi0kuBMGUxpv";

  vortex-alpha = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFzbS1u1JegLXLXNtmhMtobEtb0hz3ILjlXrbE8GSRbS";
  vortex-beta = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIARXsFJHnnFuMA8krwgEkuK1BLTJnYnYQoCwmtD9QMUH";
  vortex-gamma = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOVsHZ4MdKdVe0wmPskTGtGicwDlvmDmI9CTYvxdAlJ";

  vortex = [ vortex-alpha vortex-beta vortex-gamma ];
  servers = vortex ++ [ kaldir braxis endion shakuras glacius warpprism scv bunker raven nexus ];

  artanis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDoHqwLsvv8YPig397EeuiSfh7c/4meVfy9ptEt5qt9a";
  zeratul = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP9lpLAJBIP9qSneD5SbfsPp4lMa3xbeldDbWP+UmBiW";
  workstations = [ artanis zeratul ];
in
{
  "ca/password-file.age".publicKeys = users ++ [ raven ];
  "ca/intermediate-crt.age".publicKeys = users ++ [ raven ];
  "ca/intermediate-key.age".publicKeys = users ++ [ raven ];

  "cloudflare.age".publicKeys = users ++ [ kaldir endion bunker ];
  "cloudflare-tunnel.age".publicKeys = users;
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

  "kncyber/discord-bot.age".publicKeys = users ++ [ braxis ];

  "scv-key.age".publicKeys = users ++ servers ++ workstations;
  "beszel-env.age".publicKeys = users ++ servers;

  "obsidian-env.age".publicKeys = users ++ [ kaldir ];

  "garage-env.age".publicKeys = users ++ vortex;

  "wifi.age".publicKeys = users ++ [ artanis ];
}

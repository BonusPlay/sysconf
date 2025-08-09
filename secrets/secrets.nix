let
  bonus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFp8/Py31fozDvpKgvfn2lN5xYOggIo1F90DjxdhEbE5";
  users = [ bonus ];

  kaldir = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBlMeDxPYW6dBbDfeCbfpn5UJpPHjyoE7NJQitfuKVPy";
  braxis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKUkgnjpgtrJOg9oIIsxE8mmmmmc8KsSfirQu+cD4u/n";
  endion = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINuVWjxEUNQaP1Ie0p8vj8AEZNPorbwP25MuUmm7j6A/";
  shakuras = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA24tqea9vBJLiTMCgJV7q6UwKHdZAaiL8cUUO5bNd0A";
  glacius = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIY8XAAact/o1QSOfmwJOEGb7cvcDXX6BUUMCKkeNnu5";
  bunker = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzqBZOdyFfHH66glHDBvY842uQRapJefBk6hVzQM9cQ";
  raven = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPG39FzpJhP42iVzhy3dpmZyqRuKbbi94ckMLv5QWvoY";
  nexus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICGcl8ii1XpeEIn31+Z5gQR66SJJGlP0xi0kuBMGUxpv";
  prism = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMH1S1TIViBA023RLDmnB3TmvaRH1cZAml0crJbqwawA";
  plex = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+8FjZH1l0o9s7KjWioH8ibNleeUTlNCqrM0+oa9bCC";
  moria = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILqDJ0Ol5DFHWM7hASijEJ0kUbWsuw1E9t5Mmy/2e9FG";

  servers = [ kaldir braxis endion shakuras glacius bunker raven nexus prism moria plex ];
in
{
  "ca/root-crt.age".publicKeys = users ++ [ raven ];
  "ca/intermediate-crt.age".publicKeys = users ++ [ raven ];
  "ca/pkcs11-pass.age".publicKeys = users ++ [ raven ];

  "cloudflare.age".publicKeys = users ++ [ kaldir endion bunker ];
  "cloudflare-tunnel.age".publicKeys = users;
  "cloudflare/bonus.re.age".publicKeys = users ++ [ prism ];

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

  "mail/sieve-multibox.age".publicKeys = users ++ [ kaldir ];
  "mail/admin-secret.age".publicKeys = users ++ [ kaldir ];

  "nextcloud/admin-pass.age".publicKeys = users ++ [ bunker ];
  "nextcloud/basic-auth.age".publicKeys = users ++ [ bunker ];
  "nextcloud/ssl-key.age".publicKeys = users ++ [ bunker ];
  "nextcloud/onlyoffice-jwt.age".publicKeys = users ++ [ bunker ];
  "nextcloud/s3-secret.age".publicKeys = users ++ [ bunker ];

  "kncyber/discord-bot.age".publicKeys = users ++ [ braxis ];

  "beszel-env.age".publicKeys = users ++ servers;

  "obsidian-env.age".publicKeys = users ++ [ kaldir ];

  "garage-env.age".publicKeys = users ++ [ glacius ];

  "plex-claim.age".publicKeys = users ++ [ plex ];
}

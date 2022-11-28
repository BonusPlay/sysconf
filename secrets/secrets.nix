let
  bonus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFp8/Py31fozDvpKgvfn2lN5xYOggIo1F90DjxdhEbE5";
  users = [ bonus ];

  artanis = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFDM0mEeN9Z7TRf0cnx0Gpkv8at2tl0++Sr1MmxpWIZn";
  systems = [ artanis ];
in
{
  "artanis-p4net.age".publicKeys = users ++ [ artanis ];

  "wifi.age".publicKeys = users ++ [ artanis ];
}

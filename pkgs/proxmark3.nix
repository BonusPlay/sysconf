{ lib, stdenv, fetchFromGitHub, autoreconfHook, openssl, ... }:

stdenv.mkDerivation rec {
  pname = "proxmark3";
  version = "4.15864";

  src = fetchFromGitHub {
    owner = " RfidResearchGroup";
    repo = "proxmark3";
    rev = "proxmark3-v${version}";
  };

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ openssl ];
  dontDisableStatic = true;

  meta = with lib; {
    description = "Connect like there is no firewall, securely";
    homepage = "https://www.gsocket.io";
    license = licenses.bsd2;
    platforms = platforms.unix;
  };
}

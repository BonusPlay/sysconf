{ lib, stdenv, fetchFromGitHub, autoreconfHook, openssl, ... }:

stdenv.mkDerivation rec {
  pname = "gsocket";
  version = "1.4.38";

  src = fetchFromGitHub {
    owner = "hackerschoice";
    repo = "gsocket";
    rev = "v${version}";
    sha256 = "sha256-nzbiCNmpJMkxW67wHNIZhqR1QsGq/ka3C5Pl7m0YdWI=";
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

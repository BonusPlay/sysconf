{ stdenv, lib, fetchFromGitHub, glibc }:

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  pname = "udp2raw";
  version = "20200818.0";

  src = fetchFromGitHub {
    owner = "wangyu-";
    repo = "udp2raw";
    rev = "20200818.0";
    sha256 = "1pq6k5dwlv85g3fwizsq45fkgs8mg1ix4andnxrp4z2ibmycwi2f";
  };

  nativeBuildInputs = [ glibc.static ];

  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin/
    cp udp2raw $out/bin/udp2raw
    runHook postInstall
  '';

  meta = with lib; {
    description = "";
    longDescription = "A Tunnel which Turns UDP Traffic into Encrypted UDP/FakeTCP/ICMP Traffic by using Raw Socket, helps you Bypass UDP FireWalls(or Unstable UDP Environment)";
    homepage = "https://github.com/wangyu-/udp2raw";
    license = licenses.mit;
    maintainers = with maintainers; [ bonus ];
    platforms = platforms.linux;
  };
}

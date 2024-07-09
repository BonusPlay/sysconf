{ lib
, python3Packages
, fetchFromGitHub
}:
python3Packages.buildPythonPackage rec {
  pname = "pyuptimekuma";
  version = "0.0.7";
  format = "pyproject";

  propagatedBuildInputs = with python3Packages; [
    aiohttp
    prometheus-client
    cchardet
    aiodns
  ];

  src = fetchFromGitHub {
    owner = "meichthys";
    repo = pname;
    rev = "refs/tags/v${version}";
    hash = "sha256-NsTba8k1h9sYO2H+fwGcHDvofVGpWqjtfTZveTy4R3E=";
  };

  meta = with lib; {
    description = " Simple Python wrapper for Uptime Kuma";
    homepage = "https://github.com/meichthys/pyuptimekuma";
    license = licenses.mit;
    #maintainers = with maintainers; [ nyanloutre ];
  };
}

{ lib
, fetchFromGitHub
, ghidra
}:
ghidra.buildGhidraExtension {
  pname = "findcrypt";
  version = lib.getVersion ghidra;

  src = fetchFromGitHub {
    owner = "antoniovazquezblanco";
    repo = "GhidraFindcrypt";
    rev = "v3.0.1";
    hash = "sha256-FSRuZtVEErEo4z134XRSsYcIccs/F41R2ydnBy+992o=";
  };

  meta = with lib; {
    description = "Ghidra analysis plugin to locate cryptographic constants";
    homepage = "https://github.com/antoniovazquezblanco/GhidraFindcrypt";
    downloadPage = "https://github.com/antoniovazquezblanco/GhidraFindcrypt/releases/tag/v3.0.1";
    license = licenses.gpl3;
  };
}

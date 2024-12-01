{ lib
, fetchFromGitHub
, ghidra
}:
ghidra.buildGhidraScripts {
  pname = "GhidraCtrlP";
  version = "unstable-2024-12-01";

  src = fetchFromGitHub {
    owner = "msm-code";
    repo = "GhidraCtrlP";
    rev = "9f7ebd13b8ae8dec87b5c1f090bedf3fbc6d301e";
    sha256 = "sha256-NEVnuCGFbRLyYs2awz0ObtJeRmfp1hxTrmkQomaikxU=";
  };

  meta = {
    description = "Ctrl+P plugin for Ghidra: quick search and command palette.";
    homepage = "https://github.com/msm-code/GhidraCtrlP";
    maintainers = [ lib.maintainers.BonusPlay lib.maintainers.msm ];
  };
}

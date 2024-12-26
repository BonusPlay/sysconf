{ lib
, fetchFromGitHub
, ghidra
}:
ghidra.buildGhidraScripts {
  pname = "GhidraLib";
  version = "unstable-2024-12-26";

  src = fetchFromGitHub {
    owner = "msm-code";
    repo = "ghidralib";
    rev = "14274fd2a095ad4a8764bee36ee7541f65cedc9e";
    sha256 = "sha256-SJf2n5nqQ5AtIXVsbMdK45FP4r89TcLVr96LlK3xjpc=";
  };

  meta = {
    description = "A Pythonic Ghidra standard library";
    homepage = "https://github.com/msm-code/ghidralib";
    maintainers = with lib.maintainers; [ BonusPlay msm ];
  };
}

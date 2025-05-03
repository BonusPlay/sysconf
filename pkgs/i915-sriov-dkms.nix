# https://github.com/vadika/nixos-config/blob/main/i915-iov.nix
{ stdenv, kernel, lib, xz, fetchFromGitHub, ... }:
stdenv.mkDerivation {
  pname = "i915-sriov-dkms";
  version = "2025.03.27";

  src = fetchFromGitHub {
    owner = "strongtz";
    repo = "i915-sriov-dkms";
    rev = "master";
    sha256 = "sha256-KDEFKa7bgDsm/GCvYDFObNDoZn2c71oaQlgYMAN2B0I=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies ++ [ xz ];

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  buildPhase = ''
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M=$(pwd) \
      KERNELRELEASE=${kernel.modDirVersion}
  '';


  installPhase = ''
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/extra
    ${lib.getExe xz} -z -f i915.ko
    cp i915.ko.xz $out/lib/modules/${kernel.modDirVersion}/extra/i915-sriov.ko.xz
  '';

  meta = with lib; {
    description = "Custom module for i915 SRIOV support";
    homepage = "https://github.com/strongtz/i915-sriov-dkms";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}

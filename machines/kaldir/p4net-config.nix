{
  p4subnet = "198.18.0.0/16";
  peers = {
    chivay = {
      listenPort = 51820;
      ASN = 65001;
      linkIP = "198.18.1.1";
      publicKey = "n95378M/NgKYPLl2vpxYA32tLt8JJ3u3BsNP0ykSiS8=";
      endpoint = "130.61.129.131:51820";
      shortName = "chv";
    };
    dominikoso = {
      listenPort = 51821;
      ASN = 65057;
      linkIP = "198.18.57.1";
      publicKey = "O9E4d7jJaguaZLgosbPhpWUKA8EYX2doMTsJeMiC3W8=";
      endpoint = "duck.dominikoso.me:51821";
      shortName = "dmk";
    };
    msm = {
      listenPort = 51822;
      ASN = 65070;
      linkIP = "198.18.70.1";
      publicKey = "3hnEZtMv/k9PnoSAbEMrccG6bA3Paq1vwOafppGJlRc=";
      endpoint = "145.239.81.240:51820";
      shortName = "msm";
    };
  };
}

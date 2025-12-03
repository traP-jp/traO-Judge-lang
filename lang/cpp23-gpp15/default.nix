{pkgs}:
pkgs.stdenv.mkDerivation {
  pname = "cpp23-gpp15";
  version = "1.0";
  src = ./.;
  buildInputs = with pkgs; [
    gcc15
    boost
    eigen
    gmp
    ac-library
  ];
  buildPhase = ''
    ${pkgs.gcc15}/bin/g++ -std=c++23 -o main main.cpp -lgmp -lgmpxx
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp main $out/bin/$pname
  '';
}
